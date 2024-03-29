#!/bin/bash
nVERSION="1.3.6"
vVERSION="3.0.3"
CUDIR=`pwd`
bin_mkdir=`which mkdir`
bin_cp=`which cp`
bin_mv=`which mv`
bin_rm=`which rm`
varnish_prefix="/usr/local/varnish"
RED='\033[01;31m'
GREEN='\033[01;32m'
MOUVE='\033[01;35m'
WHITE='\033[01;1;37m'
DYELLOW='\033[01;33m'
YELLOW='\033[01;1;33m'                                                                                                                                       
DGREEN='\033[01;32m'                                                                                                                                         
RESET='\033[0m'                                                                                                                                              
clear

echo -e  "Checking  cPanel installation.."

if [   -d  "/usr/local/cpanel" ]; then
     echo -e "$GREEN cPanel YES $RESET"
else
        echo -e "$RED cPanel  NO $RESET"
        exit 0
fi
header() {
clear
echo -e "$GREEN          ************************************************************$RESET"
echo -e "$GREEN          *$RESET$WHITE      Varnish for cPanel Installation V 0.1          $GREEN*$RESET"
echo -e "$GREEN          ************************************************************$RESET"
echo " "
echo " "
sleep 2
trap "" 2 20
}
error() {
clear
echo -e "$RED =======ERROR=======$RESET"
}

header
echo -e "$GREEN Installing mailx zlib-devel pcre-devel openssl-devel $RESET"
#                 yum -y install mailx zlib-devel pcre-devel openssl-devel >/dev/null 2>&1
clear

if  which incrond
            then
            echo " $GREEN Found an existing incron installation .. $RESET "
else
             OS=`cat /etc/redhat-release|awk '{print int($3)}'`
             bit=`uname -i`
                    if [ $bit = "i386" ] || [ $bit = "i686" ] || [ $bit = "i586" ] ; then
                             rpm -ivh $CUDIR/packages/$OS/i386/*
                     else
                            rpm -ivh $CUDIR/packages/$OS/x86_64/*

        fi
fi
echo -e  "Checking cPanel perl modules"

if [ ! -f /usr/local/cpanel/Cpanel/PublicAPI.pm ]; then
                error
               echo "Unable to find Cpanel::PublicAPI. This version of Varnish for cPanel"
               echo "requires Cpanel::PublicAPI."
               CPVERSION=$(cat /usr/local/cpanel/version)
               echo "You are currently running cPanel version $CPVERSION."
               echo "You should be running at least 11.32 to have Cpanel::PublicAPI."
               echo "Please update cPanel by running /scripts/upcp"
               echo "and then try installing Varnish for cPanel  again."
               exit;
fi
clear
echo ""
echo ""
echo "############################################################"
echo "# Installing Required Perl Modules. This may take a minute.#"
echo "# If any module installs fail, you will need to manually   #"
echo "# install the module using CPAN or /scripts/perlinstaller. #"
echo "############################################################"
echo ""
echo ""
REQUIREDMODULES=( "IPC::Open3" "JSON::Syck" "Data::Dumper" "XML::DOM" "Getopt::Long" "XML::Simple" )
NEEDSCHECK=()
NOTINSTALLED=()
ALLINSTALLED=1

PERLRESULT=$( perl -MCGI -e "1" 2>&1)
if [[ $PERLRESULT != "" ]]; then
        for i in "${REQUIREDMODULES[@]}"
        do
                echo "installing $i"
                echo "....."
                perl -MCPAN -e "install $i" >/dev/null 2>&1
        done
else
#Otherwise, test each module before install
        for i in "${REQUIREDMODULES[@]}"
        do
          foundmodule=$(perl -M$i -e "1" 2>&1)
          if [[ "$foundmodule" != "" ]]; then
             echo "$i is NOT installed"
                 echo "installing $i"
                 echo "....."
                 perl -MCPAN -e "install $i" >/dev/null 2>&1
                 echo "....."
                 NEEDSCHECK=( "${NEEDSCHECK[@]}" "$i" ) #prevent unset issues with array -1
          fi
        done
fi


SIZEOFNEEDS=${#NEEDSCHECK[@]}
if [[ "$SIZEOFNEEDS" -ge "1" ]]; then
        echo "$GREEN Testing the perl modules we just installed $RESET"
        echo "....."
        for i in "${NEEDSCHECK[@]}"
        do
                ismodulethere=$(perl -M$i -e "1" 2>&1)
                if [[ "$ismodulethere" == "" ]]; then
                        echo "$i is installed properly"
                        echo "....."
        else
                        echo "$i is NOT installed"
                        echo "....."
                        ALLINSTALLED=0
                        NOTINSTALLED=( "${NOTINSTALLED[@]}" "$i" )
                fi
        done

fi

if [[ "$ALLINSTALLED" != 1 ]]; then
        error
        echo "There was an error verifying that all required perl modules are installed."
        echo "The following perl modules could not be installed: "
        for i in "${NOTINSTALLED[@]}"
        do
                echo "$i"
        done
        echo "You can try installing these modules by running" 
        echo "/scripts/perlinstaller <module_name>"
        echo "for each module name listed above."
        echo "If you are unable to install the perl modules, please contact"
        echo "Varnish for cPanel support for assistance."
        echo "Support Address: prajithpalakkuda@gmail.com"
        exit
else
        echo ".....done"
fi
clear
echo -e "$GREEN Checking for previous installation .. $RESET"
      if [ -e  "/usr/local/cpanel/whostmgr/cgi/addon_nginx.cgi" ]; then
               echo -e "$GREEN Varnish for cPanel already installed $RESET"
clear
echo -e "$GREEN Backing up current version $RESET"
               cd /root/
               $bin_mkdir -p /root/varnish-cpanel-archive
               cd /root/varnish-cpanel-archive
               $bin_cp -prf $varnish_prefix/etc/varnish /root/varnish-cpanel-archive/
               $bin_cp -prf $varnish_prefix/var /root/varnish-cpanel-archive/
               $bin_cp -prf /etc/sysconfig/varnish /root/varnish-cpanel-archive/sys.varnish
               echo -e "Backup completed"
               echo " "
               echo " "
clear
echo -e "$GREEN Removing olde version $RESET"
               $bin_rm -rvf /scripts/postwwwacct
               $bin_rm -rvf /scripts/installmod-rpf
               $bin_rm -rvf /scripts/posteasyapache
               $bin_rm -rvf /scripts/preeasyapache
               $bin_rm -rvf /scripts/rebuildvhost
               $bin_rm -rvf /etc/init.d/varnish
               $bin_rm -rvf /etc/sysconfig/varnish
               $bin_rm -rvf /scripts/genevarnishconf
               $bin_rm -rvf /scripts/purgedomains.php
               $bin_rm -rvf /scripts/purgecache
               $bin_rm -rvf /scripts/prekillacct
               $bin_rm -rvf /scripts/whmapi.pl
               $bin_rm -rvf /scripts/adjustwrap
               $bin_rm -rvf /scripts/checkuserdomains
               $bin_rm -rvf /scripts/getfilettl
               $bin_rm -rvf /scripts/restartcheck
               $bin_rm -rvf /scripts/updatevarnishcpanel
               $bin_rm -rvf /scripts/varnishurlexlude
               $bin_rm -rvf /usr/local/cpanel/hooks/addondomain/addaddondomain
               $bin_rm -rvf /usr/local/cpanel/hooks/subdomain/addsubdomain
               $bin_rm -rvf /usr/local/cpanel/hooks/addondomain/deladdondomain
               $bin_rm -rvf /usr/local/cpanel/hooks/subdomain/delsubdomain
               $bin_rm -rvf /usr/local/cpanel/hooks/park/park
               $bin_rm -rvf /usr/local/cpanel/hooks/park/unpark
               $bin_rm -rvf $varnish_prefix
               cat /var/spool/cron/root | egrep -v "checkuserdomains|restartcheck|tmpwatch" > /tmp/cron.tmp
               mv -f /tmp/cron.tmp /var/spool/cron/root
clear
echo -e "$GREEN Installing scripts $RESET"
               cd $CUDIR
               chown -R root.root conf/
               chown -R root.root scripts/
               chown -R root.root cgi/
               chmod 700 scripts/* -R
               $bin_cp -prf  scripts/* /scripts/
               $bin_cp -prf  cgi/* /usr/local/cpanel/whostmgr/docroot/cgi/

else
clear
echo -e "$GREEN Installing scripts $RESET"
               cd $CUDIR
               chown -R root.root conf/
               chown -R root.root scripts/
               chown -R root.root cgi/
               chmod 700 scripts/* -R
               $bin_cp -prf  scripts/* /scripts/
               $bin_cp -prf  cgi/* /usr/local/cpanel/whostmgr/docroot/cgi/
fi
clear
echo -e "$GREEN Installing WHM/cPanel hooks $RESET"
               cd $CUDIR
               $bin_mkdir -p /usr/local/cpanel/hooks/addondomain
               $bin_mkdir -p /usr/local/cpanel/hooks/subdomain
               $bin_mkdir -p /usr/local/cpanel/hooks/park
               $bin_cp -prvf hooks/addaddondomain  /usr/local/cpanel/hooks/addondomain/addaddondomain
               $bin_cp -prvf hooks/addsubdomain    /usr/local/cpanel/hooks/subdomain/addsubdomain
               $bin_cp -prvf hooks/deladdondomain  /usr/local/cpanel/hooks/addondomain/deladdondomain
               $bin_cp -prvf hooks/delsubdomain    /usr/local/cpanel/hooks/subdomain/delsubdomain
               $bin_cp -prvf hooks/park            /usr/local/cpanel/hooks/park/park
               $bin_cp -prvf hooks/unpark          /usr/local/cpanel/hooks/park/unpark
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/postwwwacct --describe "Varnish for cPanel" --category Whostmgr --event Accounts::Create --stage post >/dev/null 2>&1
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/prekillacct --describe "Varnish for cPanel" --category Whostmgr --event Accounts::Remove --stage pre >/dev/null 2>&1
sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/varnish \$ARGV/g" /usr/local/apache/bin/apachectl
sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/varnish \$ARGV/g" /etc/init.d/httpd

clear
echo -e "$GREEN Registering  hooks $RESET"
               /usr/local/cpanel/bin/register_hooks

clear         

echo -e "$GREEN Adding services to chksrvd $RESET"
                 cd $CUDIR
                 $bin_cp -prvf conf/chksrv.d/* /etc/chkserv.d/
                 echo "varnish:1" >> /etc/chkserv.d/chkservd.conf 
                 sed -i "s/80/82/" /etc/chkserv.d/httpd
clear
echo -e "$GREEN Creating varnish system user $RESET"
               /usr/sbin/useradd varnish -s /sbin/nologin
clear
echo -e "$GREEN startig varnishcpanel installation $RESET"
               cd $CUDIR/packages/
               $bin_cp -prf  $CUDIR/conf/varnishcpanel /etc/init.d/varnishcpanel
               chmod 775 /etc/init.d/varnishcpanel
               chkconfig varnishcpanel on
echo -e "$GREEN varnishcpanel installation completed $RESET"
clear
echo -e "$GREEN startig varnish installation $RESET"
              cd $CUDIR/packages/
              tar -zxf docutils-0.7.tar.gz
              cd docutils-0.7/
              ./setup.py install  >/dev/null 2>&1
              sleep 1
              cd $CUDIR/packages/
              tar -zxf varnish-$vVERSION.tar.gz
              cd varnish-$vVERSION
              make clean 
              make distclean 
              ./configure --prefix=/usr/local/varnish/  && make  && make install
              $bin_rm -rvf /usr/local/varnish/etc/varnish/default.vcl
              $bin_cp -pvr $CUDIR/conf/varnishconf/*  /usr/local/varnish/etc/varnish/
              $bin_cp -pvr $CUDIR/conf/varnish /etc/init.d/varnish
              $bin_cp -pvr $CUDIR/conf/varnish.sys /etc/sysconfig/varnish
              mkdir /usr/local/varnish/var/run/
echo -e "$GREEN Varnish installation completed $RESET" 
clear
echo -e "$GREEN Creating cron $RESET"
              $bin_cp -prf /var/spool/cron/root /var/spool/cron/root-bak
              echo "* * * * *  /bin/sh /scripts/restartcheck" >> /var/spool/cron/root
              echo '/var/cpanel/users IN_MODIFY,IN_NO_LOOP /scripts/createvhost.pl $#' >>/var/spool/incron/root
              /etc/init.d/incrond restart >/dev/null 2>&1
              /etc/init.d/crond restart >/dev/null 2>&1
clear
echo -e "$GREEN Building varnish configuration files $RESET"
             /scripts/genevarnishconf
             /etc/init.d/varnish restart
             /sbin/chkconfig varnish on
             clear

echo -e "$GREEN switching to Varnish for cPanel $RESET"
               if grep "apache_port"  /var/cpanel/cpanel.config  > /dev/null ; then
               sed -i  's/apache_port=0.0.0.0:80/apache_port=0.0.0.0:82/g'  /var/cpanel/cpanel.config
               /usr/local/cpanel/whostmgr/bin/whostmgr2 --updatetweaksettings >/dev/null 2>&1
               else
               echo 'apache_port=0.0.0.0:82'  >> /var/cpanel/cpanel.config
               /usr/local/cpanel/whostmgr/bin/whostmgr2 --updatetweaksettings >/dev/null 2>&1
               fi
               /scripts/rebuildhttpdconf >/dev/null 2>&1
               /scripts/restartsrv_httpd >/dev/null 2>&1
               /scripts/installmod-rpf >/dev/null 2>&1
echo -e "$GREEN starting Varnish for cPanel $RESET"
                ps aux|grep varnish|awk '{print $2}'|xargs kill -9 >/dev/null 2>&1
               /etc/init.d/varnish restart
               /etc/init.d/httpd restart >/dev/null 2>&1
echo  -e "$GREEN Checking Firewall $RESET"
               if [ -e "/etc/csf/csf.conf" ]; then
                    /scripts/csf_fix.pl
                else 
                     ERROR=1
                fi
clear
echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
echo -e "$RESET$WHITE                     Installation Completed $GREEN.$RESET"
echo -e "$RESET$WHITE            Please Go to  WHM->PLUGIN->APACHEBOOSTER $GREEN.$RESET"
echo -e "$RESET$WHITE             Please run the following command /etc/init.d/httpd restart $GREEN.$RESET"
echo -e "$RESET$WHITE         Please feel free to contact us, if you need any help $GREEN.$RESET"
echo -e "$RESET$WHITE                      EMAIL: prajithpalakkuda@gmail.com $GREEN.$RESET"
echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"

if [ "$ERROR" ]; then
    echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
     echo -e "$RESET$RED        Please enable port 82,8082 and 6082 in your firewall $RED.$RESET"
    echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
fi
