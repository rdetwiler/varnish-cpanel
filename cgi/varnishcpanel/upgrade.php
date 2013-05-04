<?php
// @todo fix this and add upgrade file
$RVERSION = `/usr/bin/curl -s http://prajith.in/version.txt`;
$LVERSION = `/bin/cat /usr/local/cpanel/whostmgr/cgi/nginx/version.txt`;
?>
<!DOCTYPE html>
<html>
<head>
<link href="styleu.css" rel="stylesheet" type="text/css" media="screen" />
<meta charset="utf-8" />
</head>
<body>
<div id="contentMain" class="contentPadding">
  <?php
    if ($LVERSION==$RVERSION) {
      echo "<div class=\"success\">
        <p>Already uptodate </p></div>";
    }
    else {
      echo "<div class=\"error\">
              <p>Version $RVERSION is now available. Please reffer belw docs to upgrade.</p>
            </div>";
    }
  ?>
  <div id="main">
    <div id="clearzone2"></div>
    <div id="mainindexcontect">
      <div id="clearzone1"></div>
      <div id="welcomemessage">
        <p>Please upgrade the Varnish for cPanel package only from Terminal.
          You can simply upgrade it by running  predefined script: /scripts/updatevarnishcpanel
          Email: info@redyhost.com
      </div>
    </div>
  </div>
  <?php include('footer.php');
  ?>
</div>

