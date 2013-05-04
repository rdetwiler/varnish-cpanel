#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
  if 0;

#!/usr/bin/perl
BEGIN { unshift @INC, '/usr/local/cpanel', '/scripts/'; }

use ApacheBooster;
use Cpanel::DIp         ();
use Cpanel::Logger;
my $logger = Cpanel::Logger->new( { alternate_logfile => "/var/log/apachebooster.log" } );
my $mainip = Cpanel::DIp::getmainip();
my $mydomain = $ARGV[0];

if (! $mydomain) {
   &create_ini_file();
   my $config_file = "/tmp/apachebooster_ini";
   my $config = &ReadConfig($config_file);

   open (FILE, "</tmp/apachebooster_ini_tmp") or die $!;
       while ($listdomain = <FILE>) {
          chomp $listdomain;
          if ( $config->{"$listdomain"}->{'IP'} eq "$mainip" ) {
           $IPPORT = $mainip . ":80";
} elsif ( $config->{"$listdomain"}->{'IP'} eq "" ) {
         $IPPORT = $mainip . ":80";
} else {
        $IPPORT = $config->{"$listdomain"}->{'IP'} . ":80";
 }
    if ( !-d "/usr/local/nginx/vhost/" ) {
           mkdir("/usr/local/nginx/vhost/");
  }
  open($file, ">/usr/local/nginx/vhost/" . $config->{"$listdomain"}->{'DOMAIN'} . ".conf");
    my $conf = <<CONFIG;
server {
    access_log off;
    error_log  logs/vhost-error_log warn;
    listen   $IPPORT;
    server_name $config->{"$listdomain"}->{'DOMAIN'}  $config->{"$listdomain"}->{'ALIAS'};
  location ~* ^.+.(jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|iso|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|mp3|ogv|ogg|flv|swf|mpeg|mpg|mpeg4|mp4|avi|wmv|js|css)\$ {
              expires           7d;
              error_page  404 = \@custom;
              error_page  500 = \@inerror;
              root  $config->{"$listdomain"}->{'DOCUMENTROOT'};
              log_not_found  off;
  }
    location ~ /\.ht {
          deny all;
      }

   location / {
           log_not_found  off;
           client_max_body_size    2000m;
           client_body_buffer_size 512k;
           proxy_next_upstream error;
           proxy_send_timeout   400;
           proxy_read_timeout   400;
           proxy_buffer_size    32k;
           proxy_buffers     16 32k;
           proxy_busy_buffers_size 64k;
           proxy_temp_file_write_size 64k;
           proxy_connect_timeout 400s;

           proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
           proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
           proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
           proxy_set_header   Host   \$host;
           proxy_set_header   X-Real-IP  \$remote_addr;
           proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
      }

   location \@custom {
           internal;
           client_max_body_size    2000m;
           client_body_buffer_size 512k;
           proxy_next_upstream error;
           proxy_send_timeout   400;
           proxy_read_timeout   400;
           proxy_buffer_size    32k;
           proxy_buffers     16 32k;
           proxy_busy_buffers_size 64k;
           proxy_temp_file_write_size 64k;
           proxy_connect_timeout 400s;
           proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
           proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
           proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
           proxy_set_header   X-Real-IP  \$remote_addr;
           proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
     }
         
  location \@inerror {
          internal;
          client_max_body_size    2000m;
          client_body_buffer_size 512k;
          proxy_next_upstream error;
          proxy_send_timeout   400;
          proxy_read_timeout   400; 
          proxy_buffer_size    32k;
          proxy_buffers     16 32k;
          proxy_busy_buffers_size 64k;
          proxy_temp_file_write_size 64k;
          proxy_connect_timeout 400s;

          proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
          proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
          proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
          proxy_set_header   Host   \$host;
          proxy_set_header   X-Real-IP  \$remote_addr;
          proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        
    }
}

CONFIG
  print($file $conf);

  close $file;
  }
close FILE;
} else {
       if ( $mydomain =~".lock" ) {
                  $logger->info("testesteestest $mydomain");
                    exit;
        } else {
       if ($mydomain =~/^((([a-z]|[0-9]|\-)+)\.)+([a-z])+$/i) {
             $mydomains=$mydomain;
   } else {
            if ( -f "/var/cpanel/users/" . "$mydomain" ) {
            $mydomains=&getusername($mydomain);
   } else {
              die "syntax malformed";
  }
 }
}
    &create_S_Domain("$mydomains");
  my $config_file = "/tmp/apachebooster_ini";
   my $config = &ReadConfig($config_file);
   my $listdomain = $mydomains;
if ( $config->{"$listdomain"}->{'USER'} ) {
 if ( $config->{"$listdomain"}->{'IP'} eq "$mainip" ) {
    $IPPORT = $mainip . ":80";
  } elsif ( $config->{"$listdomain"}->{'IP'} eq "" ) {
         $IPPORT = $mainip . ":80";
  } else {
        $IPPORT = $config->{"$listdomain"}->{'IP'} . ":80";
 }
  if (!-d "/usr/local/nginx/vhost/" ) {
           mkdir("/usr/local/nginx/vhost/");
  }
  open($file, ">/usr/local/nginx/vhost/" . $config->{"$listdomain"}->{'DOMAIN'} . ".conf");
  my $conf = <<CONFIG;
server {
    access_log off;
    error_log  logs/vhost-error_log warn;
    listen  $IPPORT;
    server_name $config->{"$listdomain"}->{'DOMAIN'}  $config->{"$listdomain"}->{'ALIAS'};
  location ~* ^.+.(jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|iso|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|mp3|ogv|ogg|flv|swf|mpeg|mpg|mpeg4|mp4|avi|wmv|js|css)\$ {
              expires           7d;
              error_page  404 = \@custom;
              error_page  500 = \@inerror;
              root  $config->{"$listdomain"}->{'DOCUMENTROOT'};
              log_not_found  off;
  }
    location ~ /\.ht {
          deny all;
      }

   location / {
           log_not_found  off;
           client_max_body_size    2000m;
           client_body_buffer_size 512k;
           proxy_next_upstream error;
           proxy_send_timeout   400;
           proxy_read_timeout   400;
           proxy_buffer_size    32k;
           proxy_buffers     16 32k;
           proxy_busy_buffers_size 64k;
           proxy_temp_file_write_size 64k;
           proxy_connect_timeout 400s;

           proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
           proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
           proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
           proxy_set_header   Host   \$host;
           proxy_set_header   X-Real-IP  \$remote_addr;
           proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
      }

   location \@custom {
           internal;
           client_max_body_size    2000m;
           client_body_buffer_size 512k;
           proxy_next_upstream error;
           proxy_send_timeout   400;
           proxy_read_timeout   400;
           proxy_buffer_size    32k;
           proxy_buffers     16 32k;
           proxy_busy_buffers_size 64k;
           proxy_temp_file_write_size 64k;
           proxy_connect_timeout 400s;
           proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
           proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
           proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
           proxy_set_header   X-Real-IP  \$remote_addr;
           proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
     }
         
  location \@inerror {
          internal;
          client_max_body_size    2000m;
          client_body_buffer_size 512k;
          proxy_next_upstream error;
          proxy_send_timeout   400;
          proxy_read_timeout   400; 
          proxy_buffer_size    32k;
          proxy_buffers     16 32k;
          proxy_busy_buffers_size 64k;
          proxy_temp_file_write_size 64k;
          proxy_connect_timeout 400s;

          proxy_redirect  http://www.$config->{"$listdomain"}->{'DOMAIN'}:8082   http://www.$config->{"$listdomain"}->{'DOMAIN'};
          proxy_redirect  http://$config->{"$listdomain"}->{'DOMAIN'}:8082   http://$config->{"$listdomain"}->{'DOMAIN'};
          proxy_pass   http://$config->{"$listdomain"}->{'IP'}:8082;
          proxy_set_header   Host   \$host;
          proxy_set_header   X-Real-IP  \$remote_addr;
          proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        
    }
}

CONFIG
  print($file $conf);

  close $file;
 }

}
