# www

### userinfo.php
simple userinfo script from php, formatted friendly for getting information via the terminal.  can be called very easily;

> curl -s example.com/userinfo.php | awk '/REMOTE_ADDR/ {print $2}'

```
USER INFORMATION
---------------------------------------
HOME                           /var/www
TERM                           linux
SHELL                          /bin/bash
PHP_FCGI_CHILDREN              6
HTTP_ACCEPT_LANGUAGE           en-US,en;q=0.8
HTTP_ACCEPT_ENCODING           gzip, deflate, sdch
HTTP_DNT                       1
HTTP_ACCEPT                    text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
HTTP_USER_AGENT                Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36
HTTP_UPGRADE_INSECURE_REQUESTS 1
HTTP_CACHE_CONTROL             max-age=0
HTTP_CONNECTION                keep-alive
HTTP_HOST                      server.example.com
REDIRECT_STATUS                200
HTTPS                          
SERVER_NAME                    www.example.com
SERVER_PORT                    80
SERVER_ADDR                    140.216.83.12
REMOTE_PORT                    51642
REMOTE_ADDR                    170.172.91.68
SERVER_SOFTWARE                nginx/1.2.1
GATEWAY_INTERFACE              CGI/1.1
SERVER_PROTOCOL                HTTP/1.1
DOCUMENT_URI                   /userinfo.php
REQUEST_URI                    /userinfo.php
SCRIPT_NAME                    /userinfo.php
CONTENT_LENGTH                 
CONTENT_TYPE                   
REQUEST_METHOD                 GET
QUERY_STRING                   
FCGI_ROLE                      RESPONDER
PHP_SELF                       /userinfo.php
REQUEST_TIME_FLOAT             1491962862.7097
REQUEST_TIME                   1491962862
```

