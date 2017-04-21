<?php
    if(phpversion() >= "4.2.0") {
      extract($_SERVER);
    }
    $badbot = 0;
    /* look for the IP address in the blacklist file */
    $filename = "includes/blacklist/blacklist.dat";
    $fp = fopen($filename, "r") or die ("Error opening file ... <br>\n");
    while ($line = fgets($fp,255))  {
      $u = explode(" ",$line);
      $u0 = $u[0];
      if (preg_match("/$u0/",$REMOTE_ADDR)) {$badbot++;}
    }
    fclose($fp);
    if ($badbot > 0) { /* this is a bad bot, reject it */
      sleep(12);
      print ("<html><head>\n");
      print ("<title>Site unavailable, sorry</title>\n");
      print ("</head><body>\n");
      print ("<center><h1>Welcome ...</h1></center>\n");
      print ("<p><center>Unfortunately, due to abuse, this site is temporarily not available ...</center></p>\n");
      print ("<p><center>If you feel this in error, send a mail to the hostmaster at this site,<br>
             if you are an anti-social ill-behaving SPAM-bot, then just go away.</center></p>\n");
      print ("</body></html>\n");
      exit;
    }
    ?>
