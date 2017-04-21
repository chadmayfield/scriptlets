#!/usr/bin/perl

# Version 2.2.3 (21. Sep. 2009)
# RapidShare AG OpenSource Perl Uploader. For non-commercial use only. All rights reserved. USE AT YOUR OWN RISK!

# Features:
# - Uploading to free, collector's zone and premium zone.
# - Supports MD5 check after uploads to check if the upload worked.
# - Supports upload resume to continue aborted uploads. Upload needs to be completed within 24 hours.
# - Supports new RealFolders for premium and collector's accounts.
# - Supports uploading whole directories in RealFolders.
# - Supports update modes and trash modes to update remote files without changing file IDs.

# Syntax: rsapiresume.pl <filename/folder> <free|prem|col> [login] [password] [updatemode] [trashmode]

# Update=0: Traditional uploading. No duplicate checking.
# Update=1: The lowest file ID duplicate will be overwritten if MD5 differs. Other duplicates will be handled using the trash flag.

# Trash=0: No trashing.
# Trash=1: Files will be moved to trash RealFolder (255)
# Trash=2: Files will be DELETED! (not undoable)

# To upload a file, put this script on a Linux machine with perl installed and use the following syntax:
# perl rsapiresume.pl mytestfile.rar free        (this uploads mytestfile.rar as a free user)
# perl rsapiresume.pl archive.rar prem 334 test  (this uploads archive.rar to the premium zone of login 334 with password test)
# perl rsapiresume.pl a.rar col testuser mypw    (this uploads a.rar to the collector's zone of login testuser with password mypw)

# perl rsapiresume.pl prem myfolder 334 mypw 1 1
# This uploads the folder myfolder and all subfolders to the premium zone of login 334 with password mypw.
# Update=1 will not upload files already existing with same md5. Existing but different files will be overwritten without
# changing the download link. Multiple duplicates will be moved to the RealFolder 255 (Trash), because we set the trash value to 1.

use strict;
use warnings;
use Digest::MD5("md5_hex");
use Fcntl;
use IO::Socket;
use LWP::Simple;

my ($FILE, $TYPE, $LOGIN, $PASSWORD, $UPDATEMODE, %ESCAPES, $TRASHMODE, %PARENTANDNAME_REALFOLDER);

$/ = undef;
$SIG{PIPE} = $SIG{HUP} = 'IGNORE';
$FILE = $ARGV[0] || "";
$TYPE = $ARGV[1] || "";
$LOGIN = $ARGV[2] || "";
$PASSWORD = $ARGV[3] || "";
$UPDATEMODE = $ARGV[4] || 0;
$TRASHMODE = $ARGV[5] || 0;

unless ($TYPE) { die "Syntax: $0 <filename/folder> <free|prem|col> [login] [password] [updatemode] [trashmode]\n" }
unless (-e $FILE) { die "File not found.\n" }

if (-d $FILE) {
  unless ($LOGIN and $PASSWORD) { die "Folder upload not supported for anonymous uploads.\n" }

  print "Counting all folders and files in $FILE...\n";
  my ($numfiles, $numfolders, $numbytes) = &countfiles($FILE);
  printf("You want to upload $numfiles files in $numfolders folders having $numbytes bytes (%.2f MB)\n", $numbytes / 1000000);
  if ($numfiles > 1000) { die "More than 1000 files? You should not do that...\n" }
  if ($numfolders > 100) { die "More than 100 folders? You should not do that...\n" }
  if ($numbytes > 100_000_000_000) { die "More than 100 Gigabytes? You should not do that...\n" }

  print "Uploading folder $FILE...\n";
  &listrealfolders($TYPE, $LOGIN, $PASSWORD);
  &uploadfolder($FILE, $TYPE, $LOGIN, $PASSWORD);
} else {
  &uploadfile($FILE, $TYPE, $LOGIN, $PASSWORD);
}

print "All done.\n";
exit;





sub countfiles {
  my $dir = shift || die;

  my ($filename, $numfiles, $numfolders, $numbytes, $subnumfiles, $subnumfolders, $subnumbytes);

  foreach $filename (glob("$dir/*")) {
    if ($filename =~ /\.uploaddata$/) { next }

    if (-d $filename) {
      ($subnumfiles, $subnumfolders, $subnumbytes) = &countfiles($filename);
      $numfiles += $subnumfiles;
      $numfolders++;
      $numbytes += $subnumbytes;
    } else {
      $numfiles++;
      $numbytes += -s $filename || 0;
    }
  }

  return ($numfiles || 0, $numfolders || 0, $numbytes || 0);
}





sub uploadfolder {
  my $file = shift || die;
  my $type = shift || die;
  my $login = shift || "";
  my $password = shift || "";
  my $parent = shift || 0;

  my ($realfolder, $filename, $htmllogin, $htmlpassword, $htmlname, $mode);

  $realfolder = $PARENTANDNAME_REALFOLDER{"$parent,$file"} || 0;
  $mode = "existed";

  unless ($realfolder) {
    $htmllogin = &htmlencode($login);
    $htmlpassword = &htmlencode($password);
    $htmlname = &htmlencode($file);
    $realfolder = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=addrealfolder_v1&type=$type&login=$htmllogin&password=$htmlpassword&name=$htmlname&parent=$parent") || "";
    if (not $realfolder or $realfolder =~ /^ERROR: /) { die "API Error occured: $realfolder\n" }
    $mode = "created";
    unless ($realfolder =~ /^\d+$/) { die "Error adding RealFolder: $realfolder\n" }
  }

  print "Folder $file resolved to ID $realfolder ($mode)\n";

  foreach $filename (glob("$file/*")) {
    if ($filename =~ /\.uploaddata$/) { next }
    if (-d $filename) { &uploadfolder($filename, $type, $login, $password, $realfolder) } else { &uploadfile($filename, $type, $login, $password, $realfolder) }
  }

  return "";
}





sub listrealfolders {
  my $type = shift || die;
  my $login = shift || die;
  my $password = shift || die;

  my ($htmllogin, $htmlpassword, $result, $realfolder, $parent, $name);

  $htmllogin = &htmlencode($login);
  $htmlpassword = &htmlencode($password);

  $result = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=listrealfolders_v1&login=$htmllogin&password=$htmlpassword&type=$type") || "";
  if (not $result or $result =~ /^ERROR: /) { die "API Error occured: $result\n" }

  foreach (split(/\n/, $result)) {
    ($realfolder, $parent, $name) = split(/,/, $_, 3);
    $PARENTANDNAME_REALFOLDER{"$parent,$name"} = $realfolder;
  }

  return "";
}





sub finddupes {
  my $type = shift || die;
  my $login = shift || die;
  my $password = shift || die;
  my $realfolder = shift || 0;
  my $filename = shift || "";

  my ($header, $result, $htmllogin, $htmlpassword, $htmlfilename, $fileid, $size, $killcode, $md5hex, $serverid);

  $htmllogin = &htmlencode($login);
  $htmlpassword = &htmlencode($password);
  $htmlfilename = &htmlencode($filename);
  $result = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=listfiles_v1&login=$htmllogin&password=$htmlpassword&type=$type&realfolder=$realfolder&filename=$htmlfilename&fields=size,killcode,serverid,md5hex&order=fileid") || "";

  if (not $result or $result =~ /^ERROR: /) { die "API Error occured: $result\n" }
  if ($result eq "NONE") { print "FINDDUPES: No dupe detected.\n"; return (0,0,0,0,0) }

  foreach (split(/\n/, $result)) {
    unless ($_ =~ /^(\d+),(\d+),(\d+),(\d+),(\w+)/) { die "FINDDUPES: Unexpected result: $result\n" }
    unless ($fileid) { $fileid = $1; $size = $2; $killcode = $3; $serverid = $4; $md5hex = lc($5); next }
    print "FINDDUPES: Deleting dupe $1\n";
    &deletefile($1, $3);
  }

  return ($fileid, $size, $killcode, $serverid, $md5hex);
}





sub deletefile {
  my $fileid = shift || die;
  my $killcode = shift || die;

  if ($TRASHMODE == 1) {
    print "DELETEFILE: Moving file $fileid to trash RealFolder 255.\n";
    my $result = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=movefilestorealfolder_v1&files=f$fileid"."k$killcode&realfolder=255") || "";
    if ($result ne "OK") { die "DELETEFILE: Unexpected server reply: $result\n" }
  }

  elsif ($TRASHMODE == 2) {
    print "DELETEFILE: DELETING file $fileid.\n";
    my $result = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=deletefiles_v1&files=f$fileid"."k$killcode") || "";
    if ($result ne "OK") { die "DELETEFILE: Unexpected server reply: $result\n" }
  }

  else {
    print "DELETEFILE: Doing nothing with file $fileid, because trash mode is 0.\n";
  }

  return "";
}





sub uploadfile {
  my $file = shift || die;
  my $type = shift || die;
  my $login = shift || "";
  my $password = shift || "";
  my $realfolder = shift || 0;

  my ($size, $filecontent, $md5hex, $size2, $uploadserver, $cursize, $dupefileid, $dupesize, $dupekillcode, $dupemd5hex);

# This chapter checks the file and calculates the MD5HEX of the existing local file.
  $size = -s $file || die "File $file is empty or does not exist!\n";
  print "File $file\n$size has byte. Full file MD5 is... ";
  open(FH, $file) || die "Unable to open file: $!\n";
  binmode(FH);
  $filecontent = <FH>;
  close(FH);
  $md5hex = md5_hex($filecontent);
  $size2 = length($filecontent);
  print "$md5hex\n";
  unless ($size == $size2) { die "Strange error: $size byte found, but only $size2 byte analyzed?\n" }

  if ($UPDATEMODE and $login and $password) {
    ($dupefileid, $dupesize, $dupekillcode, $uploadserver, $dupemd5hex) = &finddupes($type, $login, $password, $realfolder, $file);
    if ($md5hex eq $dupemd5hex) { print "FILE ALREADY UP TO DATE! Server rs$uploadserver.rapidshare.com in file ID $dupefileid.\n\n"; return "" }
    if ($dupefileid) { print "UPDATING FILE $dupefileid on server rs$uploadserver.rapidshare.com ($type)\n" }
  }

  unless ($uploadserver) {
    print "Getting a free upload server...\n";
    $uploadserver = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=nextuploadserver_v1") || "";
    if (not $uploadserver or $uploadserver =~ /^ERROR: /) { die "API Error occured: $uploadserver\n" }
    print "Uploading to rs$uploadserver.rapidshare.com ($type)\n";
  }

  $cursize = 0;
  while ($cursize < $size) { $cursize = &uploadchunk($file, $type, $login, $password, $realfolder, $md5hex, $size, $cursize, "rs$uploadserver.rapidshare.com:80", $dupefileid, $dupekillcode) }

  return "";
}





sub uploadchunk {
  my $file = shift || die;
  my $type = shift || die;
  my $login = shift || "";
  my $password = shift || "";
  my $realfolder = shift || 0;
  my $md5hex = shift || die;
  my $size = shift || die;
  my $cursize = shift || 0;
  my $fulluploadserver = shift || die;
  my $replacefileid = shift || 0;
  my $replacekillcode = shift || 0;

  my ($uploaddata, $wantchunksize, $fh, $socket, $boundary, $contentheader, $contenttail, $contentlength, $header, $chunks, $chunksize,
$bufferlen, $buffer, $result, $fileid, $complete, $resumed, $filename, $killcode, $remotemd5hex, $chunkmd5hex);

  if (-e "$file.uploaddata") {
    open(I, "$file.uploaddata") or die "Unable to open file: $!\n";
    ($fulluploadserver, $fileid, $killcode) = split(/\n/, <I>);
    print "RESUMING UPLOAD! Uploadserver=$fulluploadserver\nFile-ID=$fileid\nKillcode=$killcode\n";
    close(I);
    print "Requesting authorization for upload resume...\n";
    $cursize = get("http://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkincomplete_v1&fileid=$fileid&killcode=$killcode") || "";
    unless ($cursize =~ /^\d+$/) { die "Unable to resume! Please delete $file.uploaddata or try again.\n" }
    print "The upload stopped at $cursize on server $fulluploadserver.\n";
    $resumed = 1;
  }

  $wantchunksize = 1000000;

  if ($size > $wantchunksize) {
    $chunks = 1;
    $chunksize = $size - $cursize;
    if ($chunksize > $wantchunksize) { $chunksize = $wantchunksize } else { $complete = 1 }
  } else {
    $chunks = 0;
    $chunksize = $size;
  }

  print "Upload chunk is $chunksize byte starting at $cursize.\n";

  sysopen($fh, $file, O_RDONLY) || die "Unable to open file: $!\n";
  $filename = $file =~ /[\/\\]([^\/\\]+)$/ ? $1 : $file;
  $socket = IO::Socket::INET->new(PeerAddr => $fulluploadserver) || die "Unable to open socket: $!\n";
  $boundary = "---------------------632865735RS4EVER5675865";
  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="rsapi_v1"\r\n\r\n1\r\n|;

  if ($resumed) {
    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="fileid"\r\n\r\n$fileid\r\n|;
    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="killcode"\r\n\r\n$killcode\r\n|;
    if ($complete) { $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="complete"\r\n\r\n1\r\n| }
  } else {
    if ($type eq "prem" and $login and $password) { $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="login"\r\n\r\n$login\r\n| }
    if ($type eq "col" and $login and $password) { $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="freeaccountid"\r\n\r\n$login\r\n| }

    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="password"\r\n\r\n$password\r\n|;
    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="realfolder"\r\n\r\n$realfolder\r\n|;
    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="replacefileid"\r\n\r\n$replacefileid\r\n|;
    $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="replacekillcode"\r\n\r\n$replacekillcode\r\n|;

    if ($chunks) { $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="incomplete"\r\n\r\n1\r\n| }
  }

  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="filecontent"; filename="$filename"\r\n\r\n|;
  $contenttail = "\r\n$boundary--\r\n";
  $contentlength = length($contentheader) + $chunksize + length($contenttail);

  if ($resumed) {
    $header = qq|POST /cgi-bin/uploadresume.cgi HTTP/1.0\r\nContent-Type: multipart/form-data; boundary=$boundary\r\nContent-Length: $contentlength\r\n\r\n|;
  } else {
    $header = qq|POST /cgi-bin/upload.cgi HTTP/1.0\r\nContent-Type: multipart/form-data; boundary=$boundary\r\nContent-Length: $contentlength\r\n\r\n|;
  }

  print $socket "$header$contentheader";

  sysseek($fh, $cursize, 0);
  $bufferlen = sysread($fh, $buffer, $wantchunksize) || 0;
  unless ($bufferlen) { die "Error while reading file: $!\n" }
  $chunkmd5hex = md5_hex($buffer);
  print "Sending $bufferlen byte...\n";
  $cursize += $bufferlen;
  print $socket $buffer;
  print $socket $contenttail;
  print "Reading server response...\n";
  ($result) = <$socket> =~ /\r\n\r\n(.+)/s;
  unless ($result) { die "Ooops! Did not receive any valid server results?\n" }

  if ($resumed) {
    if ($complete) {
      if ($result =~ /^COMPLETE,(\w+)/) {
        print "Upload completed! Remote MD5=$1 Local MD5=$md5hex\n";
        if ($md5hex ne $1) { die "MD5 CHECK NOT PASSED!\n" }
        print "MD5 check passed. Upload OK! Saving status to rsapiuploads.txt\n\n";
        unlink("$file.uploaddata");
      } else {
        die "Unexpected server response!\n";
      }
    } else {
      if ($result =~ /^CHUNK,(\d+),(\w+)/) {
        print "Chunk upload completed! $1 byte uploaded.\nRemote MD5=$2 Local MD5=$chunkmd5hex\n\n";
        if ($2 ne $chunkmd5hex) { die "CHUNK MD5 CHECK NOT PASSED!\n" }
      } else {
        die "Unexpected server response!\n\n$result\n";
      }
    }
  } else {
    if ($result =~ /files\/(\d+)/) { $fileid = $1 } else { die "Server result did not contain a file ID.\n" }
    unless ($result =~ /File1\.3=(\d+)/ and $1 == $cursize) { die "Server did not save all data we sent.\n" }
    unless ($result =~ /File1\.2=.+?killcode=(\d+)/) { die "Server did not send our killcode.\n" }
    $killcode = $1;
    unless ($result =~ /File1\.4=(\w+)/) { die "Server did not send the remote MD5 sum.\n" }
    $remotemd5hex = lc($1);

    if ($chunks) {
      if ($result !~ /File1\.5=Incomplete/) { die "Server did not acknowledge the incomplete upload request.\n" }
      print "Chunk upload completed! $cursize byte uploaded.\nRemote MD5=$remotemd5hex Local MD5=$chunkmd5hex\n";
      if ($remotemd5hex ne $chunkmd5hex) { die "CHUNK MD5 CHECK NOT PASSED!\n" }
      print "Upload OK! Saving to rsapiuploads.txt and resuming upload...\n\n";
      open(O, ">$file.uploaddata") or die "Unable to save upload server: $!\n";
      print O "$fulluploadserver\n$fileid\n$killcode\n";
      close(O);
    } else {
      if ($result !~ /File1\.5=Completed/) { die "Server did not acknowledge the completed upload request.\n" }
      if ($md5hex ne $remotemd5hex) { die "FINAL MD5 CHECK NOT PASSED! LOCAL=$md5hex REMOTE=$remotemd5hex\n" }
      print "FINAL MD5 check passed. Upload OK! Saving status to rsapiuploads.txt\n$result";
    }

    open(O,">>rsapiuploads.txt") or die "Unable to save to rsapiuploads.txt: $!\n";
    print O $chunks ? "Initialized chunk upload for file $file.\n$result" : "Uploaded file $file.\n$result";
    close(O);
  }

  return $cursize;
}





sub htmlencode {
  my $text = shift || "";

  unless (%ESCAPES) {
    for (0 .. 255) { $ESCAPES{chr($_)} = sprintf("%%%02X", $_) }
  }

  $text =~ s/(.)/$ESCAPES{$1}/g;

  return $text;
}
