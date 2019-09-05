#!/bin/bash
#
# downr, a bash download "manager" for rapidshare/hotfile
# Copyright (C) 2007-2010 Chad Mayfield <http://chadmayfield.com/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#+-- RAPIDSHARE ACCOUNT
RSUSER="xxxxx"
RSPASS="xxxxxxx"
#+-- HOTFILE ACCOUNT
HFUSER="xxxxxxx"
HFPASS="xxxxxx"
#+-- MEGASHARES ACCOUNT
MSUSER="xxxxxxxxxxxxxxx"
MSPASS="xxxxxx"

# http://www.dslreports.com/calculator
DOWNRATE=150K #+-- in bytes per second

#+-------------
RSREGEX="http://(rapidshare.com|www.rapidshare.com)"
RSAPIDOC="http://images.rapidshare.com/apidoc.txt"
RSAPI="https://api.rapidshare.com/cgi-bin/rsapi.cgi"
RSCHECK="sub=checkfiles_v1&files=${FILEID}&filenames=${FILENAME}&incmd5=1"
RSDATA="sub=getaccountdetails_v1&withcookie=1&type=prem&login=${RSUSER}&password=${RSPASS}"
RSCOOKIE=".rscookie"
#+-------------
HFREGEX="http://(hotfile.com|www.hotfile.com)"
HFCHECK="http://hotfile.com/checkfiles.html?files="
#HFLOGIN="http://www.hotfile.com/login.php"
#HFPOST="returnto=%2F&user=${HFUSER}&pass=${HFPASS}&=Login"
#+--------------
DOWNLOADLOG=
USERAGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"


if [ $# -ne 1 ]; then
  echo "Usage: $0 LINKSFILE.txt"
else
  echo "Beginning to get `cat $1 | wc -l` files at $DOWNRATE KB/s."
  while read line;
  do
	echo "==============================================================================="
    if [ `echo $line | egrep -c "${RSREGEX}"` -gt 0 ]; then
      if [ ! -s $RSCOOKIE ]; then
		echo "No rapidshare cookie found. Creating it..."
		RESPONSE=$(curl -s --data "$RSDATA" "$RSAPI")
		COOKIE_VAL=$(echo "$RESPONSE" | sed -n "/^cookie=/ s/^.*cookie=\(.*\).*$/\1/p")
		COOKIE=".rapidshare.com TRUE / FALSE $(($(date +%s)+24*60*60)) enc $COOKIE_VAL"
		echo "$COOKIE" | tr ' ' '\t' > $RSCOOKIE
		exit 1
	  else
	    FILEID=`echo $line | awk -F "/" '{print $5}'`
        FILENAME=`echo $line | awk -F "/" '{print $6}'`
        FILESTATS=`curl -Gs "${RSAPI}?sub=checkfiles_v1&files=${FILEID}&filenames=${FILENAME}&incmd5=1"`
        FILESIZE=`echo $FILESTATS | awk -F "," '{print $3}'`
        STATUS=`echo $FILESTATS | awk -F "," '{print $5}'`
        echo "FILEHOST: RAPIDSHARE.COM"
        echo "FILEID:   $FILEID"
        echo "FILENAME: $FILENAME"
        echo "FILESIZE: `echo $FILESIZE/1024/1204|bc`Mb ($FILESIZE bytes)"
        SKIP=
        case $STATUS in
          0) echo "STATUS:   $STATUS (File Not Found)"; SKIP=1; ;;
          1) echo "STATUS:   $STATUS (File OK)";
             echo "-------------------------------------------------------------------------------"; ;;
          3) echo "STATUS:   $STATUS (Server Down)"; SKIP=1; ;;
          4) echo "STATUS:   $STATUS (Illegal File!)"; SKIP=1; ;;
          5) echo "STATUS:   $STATUS (Locked, < 10 downloads)"; SKIP=1; ;;
          *) echo "STATUS:   $STATUS (Unknown status: $status)"; SKIP=1; ;;
        esac
        if [ ! $SKIP ]; then
#          curl -L -O --cookie $RSCOOKIE $line
          curl -L -O --cookie $RSCOOKIE --limit-rate $DOWNRATE $line
        fi
      fi
    elif [ `echo $line | egrep -c "${HFREGEX}"` -gt 0 ]; then
      FILEID=`echo $line | awk -F "/" '{print $5}'`
      FILENAME=`echo $line | awk -F "/" '{print $7}' | sed s/.html//`
      #FILESTATS=`curl -Gs $HFCHECK$line | grep -A10 Results`
      FILESIZE=`curl -Gs ${HFCHECK}${line} | egrep '[MK]b|N/A' | awk 'BEGIN {FS="(<|>)"} {print $3}'`
      STATUS=`curl -Gs ${HFCHECK}${line} | egrep -c "Existent"`
      echo "FILEHOST: HOTFILE.COM"
      echo "FILEID:   $FILEID"
      echo "FILENAME: $FILENAME"
      echo "FILESIZE: $FILESIZE"
      case $STATUS in
        0) echo "STATUS:   $STATUS (File Not Found)"; SKIP=1; ;;
        1) echo "STATUS:   $STATUS (File OK)";
           echo "-------------------------------------------------------------------------------"; ;;
        *) echo "STATUS:   $STATUS (Unknown status: $status)"; SKIP=1; ;;
      esac
      if [ ! $SKIP ]; then
        echo "curl ......"
        #curl -L -O --cookie $RSCOOKIE $line
      fi
      #wget -c $TRIES --auth-no-challenge --user=$HFUSER --password=$HFPASS \
      #  --referer="" --limit-rate=${DOWNRATE} -o $WGETLOG $url
    else
      echo "Skipping unknown link."
      #echo $line
    fi
    sleep 1
  done<$1
fi
