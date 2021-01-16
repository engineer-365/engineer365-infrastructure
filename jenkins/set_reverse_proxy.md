# 设置反向代理

  例如公网访问域名是https://builder.example.com:443
  
## 用nginx做反向代理

  ```nginx
  upstream jenkins {
    keepalive 32; # keepalive connections
    server 192.168.50.121:8080; # jenkins ip and port
  }

  # Required for Jenkins websocket agents
  map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
  }

  server {
    server_name builder.example.com;

    gzip off;
 
    root html;
    index index.html index.htm;

    access_log      /var/log/nginx/jenkins/access.log;
    error_log       /var/log/nginx/jenkins/error.log;

    # pass through headers from Jenkins that Nginx considers invalid
    ignore_invalid_headers off;

    location / {
      sendfile off;
      proxy_pass         http://jenkins;
      # proxy_pass http://192.168.50.121:8080;

      proxy_redirect     default;
      proxy_http_version 1.1;

      # Required for Jenkins websocket agents
      proxy_set_header   Connection        $connection_upgrade;
      proxy_set_header   Upgrade           $http_upgrade;

      proxy_set_header   Host              $host:$server_port;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto $scheme;
      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_buffering            off; # Required for HTTP-based CLI to work over SSL
      proxy_request_buffering    off; # Required for HTTP-based CLI
      proxy_set_header Connection ""; # Clear for keepalive

      # workaround for https://issues.jenkins-ci.org/browse/JENKINS-45651
      add_header 'X-SSH-Endpoint' 'builder.example.com:22' always;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/builder.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/builder.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
  }
  ```

## 参考：
  https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-nginx/
