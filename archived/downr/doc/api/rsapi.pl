#!/usr/bin/perl

# RapidShare AG OpenSource Perl Uploader V1.0. For non-commercial use only. All rights reserved.
# Included: Uploading to free, collector's and premium-zone. The MD5-check after uploads checks if the upload worked.
# NOT included in this version: Upload-resume via new RS API.
# This is a PERL script written for experts and for coders wanting to know how to write own upload programs.
# Tested under Linux and Linux only.
# If you write your own upload-tools, please look at our rsapi.cgi calls. You need them to have fun.
#
# To upload a file, put this script on a machine with perl installed and use the following syntax:
# perl rsapi.pl mytestfile.rar             (this uploads mytestfile.rar as a free user)
# perl rsapi.pl archive.rar prem 334 test  (this uploads archive.rar to the premium-zone of login 334 with password test)
# perl rsapi.pl a.rar col testuser mypw    (this uploads a.rar to the collector's-zone of login testuser with password mypw)
#
# We will publish another version with upload resume enabled soon, but this script actually works and we actually
# want you to understand how it works and upload resume would make this script even more complex.

use strict;
use warnings;
use Digest::MD5("md5_hex");
use Fcntl;
use IO::Socket;

my ($file, $filename, $uploadpath, $size, $socket, $uploadserver, $cursize, $fh, $bufferlen, $buffer, $boundary, $header, $contentheader,
$contenttail, $contentlength, $result, $maxbufsize, $md5hex, $filecontent, $size2, %key_val, $login, $password, $zone);



# This chapter sets some vars and parses some vars.
$/ = undef;
$file = $ARGV[0] || die "Syntax: $0 <filename to upload> <free|prem|col> [login] [password]\n";
$zone = $ARGV[1] || "";
$login = $ARGV[2] || "";
$password = $ARGV[3] || "";
$maxbufsize = 64000;
$uploadpath = "l3";
$cursize = 0;
$size = -s $file || die "File $file is empty or does not exist!\n";
$filename = $file =~ /[\/\\]([^\/\\]+)$/ ? $1 : $file;



# This chapter checks the file and calculates the MD5HEX of the existing local file.
print "File $file has $size bytes. Calculating MD5HEX...\n";
open(FH, $file) || die "Unable to open file: $!\n";
$filecontent = <FH>;
close(FH);
$md5hex = uc(md5_hex($filecontent));
$size2 = length($filecontent);
print "MD5HEX is $md5hex ($size2 bytes analyzed.)\n";
unless ($size == $size2) { die "Strange error: $size bytes found, but only $size2 bytes analyzed?\n" }



# This chapter finds out which upload server is free for uploading our file by fetching http://rapidshare.com/cgi-bin/rsapi.cgi?sub=nextuploadserver_v1
if ($login and $password) { print "Trying to upload to your premium account.\n" } else { print "Uploading as a free user.\n" }
print "Uploading as filename '$filename'. Getting upload server infos.\n";
$socket = IO::Socket::INET->new(PeerAddr => "rapidshare.com:80") || die "Unable to open port: $!\n";
print $socket qq|GET /cgi-bin/rsapi.cgi?sub=nextuploadserver_v1 HTTP/1.0\r\n\r\n|;
($uploadserver) = <$socket> =~ /\r\n\r\n(\d+)/;
unless ($uploadserver) { die "Uploadserver invalid? Internal error!\n" }
print "Uploading to rs$uploadserver$uploadpath.rapidshare.com\n";



# This chapter opens our file and the TCP socket to the upload server.
sysopen($fh, $file, O_RDONLY) || die "Unable to open file: $!\n";
$socket = IO::Socket::INET->new(PeerAddr => "rs$uploadserver$uploadpath.rapidshare.com:80") || die "Unable to open port: $!\n";



# This chapter constructs a (somewhat RFC valid) HTTP header. See how we pass rsapi_v1=1 to the server to get a program-friendly output.
$boundary = "---------------------632865735RS4EVER5675865";
$contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="rsapi_v1"\r\n\r\n1\r\n|;

if ($zone eq "prem" and $login and $password) {
  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="login"\r\n\r\n$login\r\n|;
  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="password"\r\n\r\n$password\r\n|;
}

if ($zone eq "col" and $login and $password) {
  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="freeaccountid"\r\n\r\n$login\r\n|;
  $contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="password"\r\n\r\n$password\r\n|;
}

$contentheader .= qq|$boundary\r\nContent-Disposition: form-data; name="filecontent"; filename="$filename"\r\n\r\n|;
$contenttail = "\r\n$boundary--\r\n";
$contentlength = length($contentheader) + $size + length($contenttail);
$header = qq|POST /cgi-bin/upload.cgi HTTP/1.0\r\nContent-Type: multipart/form-data; boundary=$boundary\r\nContent-Length: $contentlength\r\n\r\n|;



#This chapter actually sends all the data, header first, to the upload server.
print $socket "$header$contentheader";

while ($cursize < $size) {
  $bufferlen = sysread($fh, $buffer, $maxbufsize, 0) || 0;
  unless ($bufferlen) { die "Error while sending data: $!\n" }
  print "$cursize of $size bytes sent.\n";
  $cursize += $bufferlen;
  print $socket $buffer;
}

print $socket $contenttail;



# OK, all is sent. Now lets fetch the server's reponse and analyze it.
print "All $size bytes sent to server. Fetching result:\n";
($result) = <$socket> =~ /\r\n\r\n(.+)/s;
unless ($result) { die "Ooops! Did not receive any valid server results?\n" }
print "$result >>> Verifying MD5...\n";

foreach (split(/\n/, $result)) {
  if ($_ =~ /([^=]+)=(.+)/) { $key_val{$1} = $2 }
}



# Now lets check if the result contains (and it should contain) the MD5HEX of the uploaded file and check if its identical to our MD5HEX.
unless ($key_val{"File1.4"}) { die "Ooops! Result did not contain MD5? Maybe you entered invalid login data.\n" }
if ($md5hex ne $key_val{"File1.4"}) { die qq|Upload FAILED! Your MD5HEX is $md5hex, while the uploaded file has MD5HEX $key_val{"File1.4"}!\n| }
print "MD5HEX value correct. Upload completed without errors. Saving links to rsulres.txt\n\n\n";



# Maybe you want the links saved to a logfile? Here we go.
open(O, ">>rsulres.txt");
print O $result . "\n";
close(O);



# Thats it. Have fun experimenting with this script. Now lets say...
exit;
