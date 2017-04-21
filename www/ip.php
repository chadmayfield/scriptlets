<?php

// ip.php - a very simple ip address reporting tool with no formatting to be
//          used in shell scripts with cURL and wget... (quick 'n dirty)

ob_start("ob_gzhandler");
$ip = @$_SERVER['REMOTE_ADDR'];
$hostname = gethostbyaddr($_SERVER['REMOTE_ADDR']);
$useragent = @$_SERVER['HTTP_USER_AGENT'];
// allowed hostnames
$allowed = array("xmission.com", "comcast.net", "slkc.qwest.net");

// match last two segments of hostname for eval
preg_match('/[^.]+\.[^.]+$/', $hostname, $matches);
//preg_match('/[^.]+\.[^.]+\.[^.]+$/', $hostname, $matches);

// check if $matches equals an element in $allowed array
$i = 0;
foreach ($allowed as $value) {
    // to stop possible abuse, evaluate if allowed hostname
    // matches actual hostname and allow/disallow user
    if (strcmp($matches[0], $value) == 0) {
        // if ip.php?extended is passed, show it, otherwise just the ip
        if (isset($_GET['extended'])) {
            echo "IP Address:\t" . $ip . "<br />\r\n";
            echo "Hostname:\t" . $hostname . "<br />\r\n";
            echo "User Agent:\t" . $useragent . "<br />\r\n";
            break;
        } else {
            echo $ip;
            break;
        }
    }
    
    $i++;

    // if we get through the entire loop and don't match throw error
    if ( sizeof($allowed) == $i ) {
        echo "Unauthorized, user access denied.";
    }
}

?>
