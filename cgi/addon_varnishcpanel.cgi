#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
  if 0;

#!/usr/bin/perl
#WHMADDON::VarnishCpanel
####################################
# start main


$script = "addon_varnishcpanel.cgi";

##Directory containing images files
$images = "varnishcpanel";

use lib '/usr/local/cpanel';
use Whostmgr::ACLS			();

Whostmgr::ACLS::init_acls();

print "Content-type: text/html\r\n\r\n";

if (!Whostmgr::ACLS::hasroot()) {
	print "You do not have access to this plugin.\n";
	exit();
}

print "<meta http-equiv=\"refresh\" content=\"0;url=nginx/index.html\"/>" ;


1;
