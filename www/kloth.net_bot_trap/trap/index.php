<?php
    if(phpversion() >= "4.2.0") {
      extract($_SERVER);
    }
    ?>
    <html>
    <head><title> </title>
    </head>
    <body>
    <p>There is nothing here to see. So what are you doing here ?</p>
    <p><a href="http://www.msn.com/">Go home.</a></p>
    <?php
      /* whitelist: end processing end exit */
      if (preg_match("/10\.22\.33\.44/",$REMOTE_ADDR)) { exit; }
      if (preg_match("/Super Tool/",$HTTP_USER_AGENT)) { exit; }
      /* end of whitelist */
      $badbot = 0;
      /* scan the blacklist.dat file for addresses of SPAM robots
         to prevent filling it up with duplicates */
      $filename = "../includes/blacklist/blacklist.dat";
      $fp = fopen($filename, "r") or die ("Error opening file ... <br>\n");
      while ($line = fgets($fp,255)) {
        $u = explode(" ",$line);
        $u0 = $u[0];
        if (preg_match("/$u0/",$REMOTE_ADDR)) {$badbot++;}
      }
      fclose($fp);
      if ($badbot == 0) { /* we just see a new bad bot not yet listed ! */
      /* send a mail to hostmaster */
        $tmestamp = time();
        $datum = date("Y-m-d (D) H:i:s",$tmestamp);
        $from = "badbot-watch@dplanetmayfield.com";
        $to = "chad@planetmayfield.com";
        $subject = "planetmayfield.com alert: bad robot hit";
        $msg = "A bad robot hit $REQUEST_URI $datum \n";
        $msg .= "address is $REMOTE_ADDR, agent is $HTTP_USER_AGENT\n";
        mail($to, $subject, $msg, "From: $from");
      /* append bad bot address data to blacklist log file: */
        $fp = fopen($filename,'a+');
        fwrite($fp,"$REMOTE_ADDR - - [$datum] \"$REQUEST_METHOD $REQUEST_URI $SERVER_PROTOCOL\" $HTTP_REFERER $HTTP_USER_AGENT\n");
        fclose($fp);
      }
    ?>
    </body>
    </html>
