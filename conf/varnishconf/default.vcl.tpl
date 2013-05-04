include "/usr/local/varnish/etc/varnish/cpanel.backend.vcl";
include "/usr/local/varnish/etc/varnish/vhost.vcl";

sub vcl_recv {

set req.backend = default;
include "/usr/local/varnish/etc/varnish/acl.vcl";
include "/usr/local/varnish/etc/varnish/vhost.exclude.vcl";
set req.grace = 5m;

# Handle IPv6
if (req.http.Host ~ "^ipv6.*") {
set req.http.host = regsub(req.http.host, "^ipv6\.(.*)","www\.\1");
}


# Sanitise X-Forwarded-For...
remove req.http.X-Forwarded-For;
set req.http.X-Forwarded-For = client.ip;
include "/usr/local/varnish/etc/varnish/cpanel.url.vcl";

# Normalize the Accept-Encoding header
if (req.http.Accept-Encoding) {
if (req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|flv|pdf|ico)(\?[a-z0-9\=]+)?$") {
# No point in compressing these
remove req.http.Accept-Encoding;
} elsif (req.http.Accept-Encoding ~ "gzip") {
set req.http.Accept-Encoding = "gzip";
} elsif (req.http.Accept-Encoding ~ "deflate") {
set req.http.Accept-Encoding = "deflate";
} else {
# unknown algorithm
remove req.http.Accept-Encoding;
}
}

# Normalize the Vary header
if (req.http.Vary ~ "User-Agent" && req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|flv|pdf|ico|js|css)(\?[a-z0-9\=]+)?$") {
set req.http.Vary = regsub(req.http.Vary, "(^|; ) *User-Agent,? *", "\1");
}

include "/usr/local/varnish/etc/varnish/url.exclude.vcl";

if (req.request == "PURGE") {
if (!client.ip ~ acl127_0_0_1) {error 405 "Not permitted";}
return (lookup);
}

## Default request checks
if (req.request != "GET" &&
req.request != "HEAD" &&
req.request != "PUT" &&
req.request != "POST" &&
req.request != "TRACE" &&
req.request != "OPTIONS" &&
req.request != "DELETE") {

# Non-RFC2616 or CONNECT which is weird.
return (pipe);
}

if (req.http.Authorization) {
return (pass);
}

## Pass Drupal cron jobs
if (req.url ~ "cron\.php") {
return (pass);
}

# Pass server-status
if (req.url ~ ".*/server-status$") {
return (pass);
}

# Don't cache Drupal's install.php
if (req.url ~ "install\.php") {
return (pass);
}

if (req.request != "GET" && req.request != "HEAD") {
# We only deal with GET and HEAD by default, the rest get passed direct to backend
return (pass);
}

# Don't cache Drupal logged-in user sessions
# LOGGED_IN is the cookie that earlier version of Pressflow sets
# VARNISH is the cookie which the varnish.module sets
if (req.http.Cookie ~ "(VARNISH|DRUPAL_UID|LOGGED_IN)") {
return (pass);
}

# Cache things with these extensions
if (req.url ~ "\.(js|css|jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf)(\?[a-z0-9\=]+)?$" && ! (req.url ~ "\.(php)") ) {
unset req.http.Cookie;
return (lookup);
}

# Remove has_js and Google Analytics cookies.
set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js)=[^;]*", "");

# Ignore empty cookies
if (req.http.Cookie ~ "^\s*$") {
remove req.http.Cookie;
unset req.http.Cookie;
}

return (pass);
}


sub vcl_fetch {

set beresp.ttl = 45s;
set beresp.http.Server = " Apache";

set beresp.do_gzip = true;
set beresp.do_gunzip = false;
set beresp.do_stream = false;
set beresp.do_esi = false;

set beresp.grace = 5m;

#unset beresp.http.expires;
if (req.url ~ "\.(js|css|jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf|ico)(\?[a-z0-9\=]+)?$" && !(req.url ~ "\.(php)") ) {
unset beresp.http.set-cookie;
include  "/usr/local/varnish/etc/varnish/static_file.vcl";
}
else {
include  "/usr/local/varnish/etc/varnish/dynamic_file.vcl";
}

if (beresp.status == 503 || beresp.status == 500) {
set beresp.http.X-Cacheable = "NO: beresp.status";
set beresp.http.X-Cacheable-status = beresp.status;
return (hit_for_pass);
}

if (beresp.status == 404) {
set beresp.http.magicmarker = "1";
set beresp.http.X-Cacheable = "YES";
set beresp.ttl = 20s;
return (deliver);
}

set beresp.http.magicmarker = "1";
set beresp.http.X-Cacheable = "YES";
}

sub vcl_deliver {

if (resp.http.magicmarker) {
/* Remove the magic marker */
unset resp.http.magicmarker;

#set resp.http.age = "0";
}

if (obj.hits > 0) {
#if hit add hit count
set resp.http.X-Cache = "HIT";
set resp.http.X-Cache-Hits = obj.hits;
}
else {
set resp.http.X-Cache = "MISS";
}
}
