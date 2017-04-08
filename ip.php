<?php

// ip.php - a very simple ip address reporting tool with no formatting to be
//          used in shell scripts with cURL and wget... (quick 'n dirty)

ob_start("ob_gzhandler");

$ip = @$_SERVER['REMOTE_ADDR'];
$hostname = gethostbyaddr($_SERVER['REMOTE_ADDR']);
$useragent = @$_SERVER['HTTP_USER_AGENT'];
$allowed = "xmission.com"; //allowed hostname
//$allowed = "slkc.qwest.net"; //allowed hostname

// match last segments of hostname for eval
preg_match('/[^.]+\.[^.]+$/', $hostname, $matches);
//preg_match('/[^.]+\.[^.]+\.[^.]+$/', $hostname, $matches);

// to stop possible abuse, evaluate if allowed hostname
// matches actual hostname and allow/disallow user
if ($allowed == $matches[0]){
    // ip.php?extended
    if (isset($_GET['extended'])) {
        echo "IP Address:\t" . $ip . "<br />";
        echo "Hostname:\t" . $hostname . "<br />";
        echo "User Agent:\t" . $useragent . "<br />";
    } else {
        echo $ip;
    }
} else {
    echo "Unauthorized host, user access denied.";
}

?>
