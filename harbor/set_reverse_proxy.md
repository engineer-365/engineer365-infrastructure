# 设置反向代理

  例如公网访问域名是https://docker.engineer365.org:40443
  
## 用nginx做反向代理

  ```nginx
  # this is necessary for us to be able to disable request buffering in all cases
  proxy_http_version 1.1;

  upstream harbor_portal {
    server 192.168.50.24:80;
  }

  server {
    server_name docker.engineer365.org;
    server_tokens off;

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;

    # Add extra headers
    add_header X-Frame-Options DENY;
    add_header Content-Security-Policy "frame-ancestors 'none'";

    gzip off;

    root html;
    index index.html index.htm;

    location / {
      proxy_pass http://harbor_portal;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_buffering off;
      proxy_request_buffering off;
    }

    listen 40443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/docker.engineer365.org/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/docker.engineer365.org/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
  }
  ```
