FROM alpine:3.11
LABEL maintainer "Carl Mercier <foss@carlmercier.com>"
LABEL caddy_version="1.0.4" architecture="amd64"

# Get the list with:
#   curl https://caddyserver.com/v1/api/download-page | jq '.plugins|map(.Name)'
ARG plugins=http.authz,http.awses,http.awslambda,http.cache,http.cgi,http.cors,http.datadog,http.expires,http.filter,http.forwardproxy,http.geoip,http.git,http.gopkg,http.grpc,http.ipfilter,http.jwt,http.locale,http.login,http.mailout,http.minify,http.nobots,http.permission,http.prometheus,http.proxyprotocol,http.pubsub,http.ratelimit,http.realip,http.reauth,http.recaptcha,http.restic,http.s3browser,http.supervisor,http.torproxy,http.webdav
ARG dns=tls.dns.auroradns,tls.dns.azure,tls.dns.cloudflare,tls.dns.cloudxns,tls.dns.digitalocean,tls.dns.dnsimple,tls.dns.dnsmadeeasy,tls.dns.dnspod,tls.dns.duckdns,tls.dns.dyn,tls.dns.exoscale,tls.dns.gandi,tls.dns.gandiv5,tls.dns.godaddy,tls.dns.googlecloud,tls.dns.lightsail,tls.dns.linode,tls.dns.namecheap,tls.dns.namedotcom,tls.dns.namesilo,tls.dns.ns1,tls.dns.otc,tls.dns.ovh,tls.dns.powerdns,tls.dns.rackspace,tls.dns.rfc2136,tls.dns.route53,tls.dns.vultr
ARG others=dyndns,docker,dns,net,supervisor,consul,redis,hook.service

RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        openssh-client \
        tar \
    && update-ca-certificates

# The subshell is to avoid double, leading, or following commas which cause a the download to fail
RUN curl --silent https://getcaddy.com | /bin/bash -s personal $(echo $plugins,$dns,$others | sed 's/,,/,/g; s/^,//g; s/,$//g')

RUN mkdir -p /opt/assets

EXPOSE 80 443 2015

VOLUME /var/www
VOLUME /caddy
WORKDIR /var/www
WORKDIR /caddy

ENV CADDYPATH=/caddy/.caddy
ENV RUN_ARGS=

COPY Caddyfile /caddy/
COPY index.html /var/www/
COPY Caddyfile /opt/assets/
COPY index.html /opt/assets/
COPY start.sh /

ENTRYPOINT ["/start.sh"]
