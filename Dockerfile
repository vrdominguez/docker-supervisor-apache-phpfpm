FROM ubuntu:18.04

LABEL maintainer="Víctor Rodríguez <victor@vrdominguez.es>"

# Actualizar distro y configurar zona horaria 
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 


# Instalar supervisor
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install -y --no-install-recommends supervisor \
    && mkdir -p /var/log/supervisor && mkdir -p /etc/supervisor/conf.d \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 


# Instalar apache y php
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq && apt-get install -y --no-install-recommends ca-certificates apache2 \
        php-gettext php7.2-cli php7.2-common php7.2-curl php7.2-fpm php7.2-gd php7.2-json php7.2-mysql \
        php7.2-pspell php7.2-readline php7.2-xdebug \
    && rm -f /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default-ssl.conf \
    && rm -f /var/www/html/index.html && chown www-data: /var/www/html/ \
    && a2dismod mpm_event && a2enmod rewrite proxy proxy_fcgi mpm_prefork proxy_http cgi \
    && mkdir -p /run/php/ \
    && echo '<?php  phpinfo(); ?>' > /var/www/html/index.php && chown www-data: /var/www/html/index.php \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Configuracion Apache
ADD configuraciones/virtualhost.conf /etc/apache2/sites-available/000-default.conf

# Configuraciones de servicios en supervisor 
ADD configuraciones/supervisor_apache2.conf /etc/supervisor/conf.d/apache2.conf
ADD configuraciones/supervisor_php.conf /etc/supervisor/conf.d/php.conf

# Iniciar supervisor con el contenedor
#CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
CMD ["supervisord", "-n"]
