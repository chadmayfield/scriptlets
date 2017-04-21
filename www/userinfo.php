<?php

// userinfo.php - display user information in terminal friendly way

/*
    TODO:
        + add html formatting while keeping terminal friendliness
        + add javascript detection of screen, user-agent, color depth, etc
        + add ssi information
        + add getting information from perl
*/

// enable error reporting for debuging
#ini_set('display_errors', 'On');
#error_reporting(E_ALL);

// make it terminal friendly
header("Content-Type: text/plain");

// don't expose too much information about the server
$exclude = array("SUDO_GID", "MAIL", "USER", "SUDO_UID", "LOGNAME", "USERNAME", "PATH", "SUDO_COMMAND", "SUDO_USER", "PWD", "DOCUMENT_ROOT", "SCRIPT_FILENAME");

// details: https://secure.php.net/manual/en/reserved.variables.server.php
printf("USER INFORMATION\n---------------------------------------\n");
while (list($var,$value) = each ($_SERVER)) {
    if (!in_array($var, $exclude)) {
        #printf("%-20s\n", $value);
        printf("%-30s %s\n",$var,$value);
    }
}

// does the samething as above, just with a foreach loop
#foreach($_SERVER as $key_name => $key_value) {
#    printf("%-30s %s\n",$key_name,$key_value);
#}

// dump all the arrays in the script
if (isset($_GET['dump'])) {
    printf("GLOBALS VAR_DUMP\n---------------------------------------\n");
    #var_dump(get_defined_vars());
    print_r(var_dump($GLOBALS),1);
}

?>
