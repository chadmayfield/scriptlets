<html>
<head>
<title>User Information</title>

<!-- from youtah.com, used with permission -->

<style type="text/css">
	a {color: #048;}
	a:hover {color: #06C;}

	body {
		color: #444;
		font: normal 90% Tahoma,sans-serif;
		padding-top: 10px;
	}
</style>
<script src="/mint/?js" type="text/javascript">
</script>
</head>
<body>
<h2><strong>User Information</strong></h2>
<br />
<h3>Collected via Perl</h3>
	<a href="cgi-bin/env.pl">Environment Variables in Perl</a><br />
	<br />
<h3>Collected via PHP</h3>
<blockquote>
	<?php
	
	function getip() {
	   if (getenv("HTTP_CLIENT_IP") && strcasecmp(getenv("HTTP_CLIENT_IP"), "unknown"))
	   $ip = getenv("HTTP_CLIENT_IP");
	   else if (getenv("HTTP_X_FORWARDED_FOR") && strcasecmp(getenv("HTTP_X_FORWARDED_FOR"), "unknown"))
	   $ip = getenv("HTTP_X_FORWARDED_FOR");
	   else if (getenv("REMOTE_ADDR") && strcasecmp(getenv("REMOTE_ADDR"), "unknown"))
	   $ip = getenv("REMOTE_ADDR");
	   else if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] && strcasecmp($_SERVER['REMOTE_ADDR'], "unknown"))
	   $ip = $_SERVER['REMOTE_ADDR'];
	   else
	   $ip = "unknown";
	   return($ip);
	}
	
	
	echo "<strong>DATE/TIME STAMP:</strong> ".date('l, F d, Y @ H:i:s A T')."<br />";
	echo "<strong><font color=\"red\">YOUR IP ADDRESS:</font></strong> ".getip()."<br />";
	echo '<strong>HTTP_ACCEPT</strong> '. $_SERVER["HTTP_ACCEPT"]."<br />";
	echo '<strong>HTTP_ACCEPT_LANGUAGE</strong> '. $_SERVER["HTTP_ACCEPT_LANGUAGE"]."<br />";
	echo '<strong>HTTP_CONNECTION</strong> '. $_SERVER["HTTP_CONNECTION"]."<br />";
	echo '<strong>HTTP_COOKIE</strong> '. $_SERVER["HTTP_COOKIE"]."<br />";
	echo '<strong>HTTP_HOST</strong> '. $_SERVER["HTTP_HOST"]."<br />";
	echo '<strong>HTTP_KEEP_ALIVE</strong> '. $_SERVER["HTTP_KEEP_ALIVE"]."<br />";
	echo '<strong>HTTP_USER_AGENT</strong> '. $_SERVER["HTTP_USER_AGENT"]."<br />";
	echo '<strong>REMOTE_ADDR</strong> '. $_SERVER["REMOTE_ADDR"]."<br />";
	echo '<strong>REMOTE_PORT</strong> '. $_SERVER["REMOTE_PORT"]."<br />";
	//echo '<strong>SERVER_ADDR</strong> '. $_SERVER["SERVER_ADDR"]."<br />";
	//echo '<strong>PHP_SELF</strong> '. $_SERVER["PHP_SELF"]."<br />";
	//echo "<strong>SERVER SCRIPT_FILENAME:</strong> ".$_SERVER["SCRIPT_FILENAME"]."<br />";
	echo "<strong>PHP_SELF:</strong> ".$_SERVER["PHP_SELF"]."<br />";
	echo "<strong>argv:</strong> ".$_SERVER["argv"]."<br />";
	echo "<strong>argc:</strong> ".$_SERVER["argc"]."<br />";
	echo "<strong>GATEWAY_INTERFACE:</strong> ".$_SERVER["GATEWAY_INTERFACE"]."<br />";
	echo "<strong>SERVER_NAME:</strong> ".$_SERVER["SERVER_NAME"]."<br />";
	echo "<strong>SERVER_SOFTWARE:</strong> ".$_SERVER["SERVER_SOFTWARE"]."<br />";
	echo "<strong>SERVER_PROTOCOL:</strong> ".$_SERVER["SERVER_PROTOCOL"]."<br />";
	echo "<strong>REQUEST_METHOD:</strong> ".$_SERVER["REQUEST_METHOD"]."<br />";
	echo "<strong>REQUEST_TIME:</strong> ".$_SERVER["REQUEST_TIME"]."<br />";
	echo "<strong>QUERY_STRING:</strong> ".$_SERVER["QUERY_STRING"]."<br />";
	//echo "<strong>DOCUMENT_ROOT:</strong> ".$_SERVER["DOCUMENT_ROOT"]."<br />";
	echo "<strong>HTTP_ACCEPT:</strong> ".$_SERVER["HTTP_ACCEPT"]."<br />";
	echo "<strong>HTTP_ACCEPT_CHARSET:</strong> ".$_SERVER["HTTP_ACCEPT_CHARSET"]."<br />";
	echo "<strong>HTTP_ACCEPT_ENCODING:</strong> ".$_SERVER["HTTP_ACCEPT_ENCODING"]."<br />";
	echo "<strong>HTTP_ACCEPT_LANGUAGE:</strong> ".$_SERVER["HTTP_ACCEPT_LANGUAGE"]."<br />";
	echo "<strong>HTTP_CONNECTION:</strong> ".$_SERVER["HTTP_CONNECTION"]."<br />";
	//echo "<strong>HTTP_HOST:</strong> ".$_SERVER["HTTP_HOST"]."<br />";
	echo "<strong>HTTP_REFERER:</strong> ".$_SERVER["HTTP_REFERER"]."<br />";
	echo "<strong>HTTP_USER_AGENT:</strong> ".$_SERVER["HTTP_USER_AGENT"]."<br />";
	//echo "<strong>HTTPS:</strong> ".$_SERVER["HTTPS"]."<br />";
	echo "<strong>REMOTE_ADDR:</strong> ".$_SERVER["REMOTE_ADDR"]."<br />";
	echo "<strong>REMOTE_HOST:</strong> ".$_SERVER["REMOTE_HOST"]."<br />";
	echo "<strong>REMOTE_PORT:</strong> ".$_SERVER["REMOTE_PORT"]."<br />";
	//echo "<strong>SCRIPT_FILENAME:</strong> ".$_SERVER["SCRIPT_FILENAME"]."<br />";
	//echo "<strong>SERVER_ADMIN:</strong> ".$_SERVER["SERVER_ADMIN"]."<br />";
	echo "<strong>SERVER_PORT:</strong> ".$_SERVER["SERVER_PORT"]."<br />";
	//echo "<strong>SERVER_SIGNATURE:</strong> ".$_SERVER["SERVER_SIGNATURE"]."<br />";
	echo "<strong>PATH_TRANSLATED:</strong> ".$_SERVER["PATH_TRANSLATED"]."<br />";
	echo "<strong>SCRIPT_NAME:</strong> ".$_SERVER["SCRIPT_NAME"]."<br />";
	echo "<strong>REQUEST_URI:</strong> ".$_SERVER["REQUEST_URI"]."<br />";
	echo "<strong>PHP_AUTH_DIGEST:</strong> ".$_SERVER["PHP_AUTH_DIGEST"]."<br />";
	echo "<strong>PHP_AUTH_USER:</strong> ".$_SERVER["PHP_AUTH_USER"]."<br />";
	echo "<strong>PHP_AUTH_PW:</strong> ".$_SERVER["PHP_AUTH_PW"]."<br />";
	echo "<strong>AUTH_TYPE:</strong> ".$_SERVER["AUTH_TYPE"]."<br />";
	echo "<strong>HOST BY ADDRESS:</strong> ".gethostbyaddr($_SERVER['REMOTE_ADDR']);
	?> 
	<p><a href="index.php">Go Home</a></p>
</blockquote>

<br />
<h3>Collected via JavaScript</h3>
<blockquote>
	<script>
			<!--
			if (document.all)
			var version=/MSIE \d+.\d+/
			if (!document.all)
			document.write("<strong>You're using:</strong> "+navigator.appName+" "+navigator.userAgent+"")
			else
			document.write("<strong>You're using:</strong> "+navigator.appName+" "+navigator.appVersion.match(version)+"")
			//-->
	</script>
	<br />
	<script language="Javascript"><!--
			if (self.screen) {     
					width = screen.width
					height = screen.height
			}
			
			// for NN3 w/Java
			else if (self.java) {   
				   var javakit = java.awt.Toolkit.getDefaultToolkit();
				   var scrsize = javakit.getScreenSize();       
				   width = scrsize.width; 
				   height = scrsize.height; 
			}
			else {
			
			// N2, E3, N3 w/o Java (Opera and WebTV)
			width = height = '?' 
			}
			
			document.write("<strong>Your Screen Resolution is set to:</strong> "+ width +"x"+ height +"")
				  
			//-->
	</script>
	<br />
	<script language="Javascript"><!--
			if( self.screen ) {
			numbage = screen.pixelDepth
			? Math.pow( 2, screen.pixelDepth ) // in N4
			: Math.pow( 2, screen.colorDepth ) // in E4
			}
			else { numbage = "UNKNOWN" }
			document.write( '<strong>Your screen color depth is:</strong> ' +numbage+ ' colors.' ) 
			
			//-->
	</script>
	<br />
	<script Language="JavaScript">
		document.write("<strong>The last page you just came from was:</strong> "+document.referrer+"")
	</script>
	<br />
	<script Language="JavaScript">
		//window.onerror=null;
		document.write("<strong>localhost address is:</strong> "+java.net.InetAddress.getLocalHost().getHostAddress()+"")
	</script>
<p><a href="index.php">Go Home</a></p>
</blockquote>

</body>
</html>
