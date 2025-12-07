FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get install -y tini && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/sites-enabled/default

COPY ./conf/default.conf    /etc/nginx/sites-available/ntodisoa.conf

RUN mkdir -p /etc/nginx/ssl/

RUN openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=MG/ST=Antananarivo/L=Antananarivo/O=42/OU=ntodisoa/CN=ntodisoa.42.fr/"

COPY ./conf/index.html    /var/www/html/index.html

RUN ln -s /etc/nginx/sites-available/ntodisoa.conf /etc/nginx/sites-enabled/ntodisoa.conf

EXPOSE 443

STOPSIGNAL SIGQUIT

ENTRYPOINT ["/usr/bin/tini", "--", "nginx"]

CMD [ "-g", "daemon off;"]