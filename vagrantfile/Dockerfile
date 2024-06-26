#################################
# stage builder: build and test
#################################
FROM php:8.3-apache-bullseye AS builder

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update > /dev/null
RUN apt-get install -y git libzip-dev nodejs python2 libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install zip
RUN docker-php-ext-enable zip

RUN git clone https://github.com/filegator/filegator.git /var/www/vagrantfile/
COPY vagrantfile/VagrantFile_env.sh /var/www/vagrantfile/environment.sh
COPY vagrantfile/VagrantFile_favicon.ico /var/www/vagrantfile/dist/favicon.ico
COPY vagrantfile/VagrantFile_logo.png /var/www/vagrantfile/dist/img/logo.png
COPY vagrantfile/VagrantFile_logo.svg /var/www/vagrantfile/dist/img/logo.svg
WORKDIR "/var/www/vagrantfile/"
ENV FILE_PATH=configuration.php
RUN cp configuration_sample.php $FILE_PATH && sed -i "s/100 \* 1024 \* 1024, \/\/ 100MB/20 \* 1024 \* 1024 \* 1024, \/\/ 20GB/g" $FILE_PATH  && sed -i "s/https:\/\/filegator.io\/filegator_logo.svg/img\/logo.png/g" $FILE_PATH && sed -i "s/FileGator/VagrantFile/g" $FILE_PATH && chmod +x environment.sh
RUN composer install
RUN composer require league/flysystem-sftp:^1.0 -W
RUN composer require league/flysystem-aws-s3-v3:^1.0 -W
RUN npm install
RUN npm run build
RUN vendor/bin/phpunit
RUN npm run lint
#RUN npm run test:e2e
RUN rm -rf node_modules frontend tests docs .git .github
RUN rm README.md couscous.yml repository/.gitignore babel.config.js cypress* .env* .eslint* .gitignore jest.* .php_cs* phpunit* postcss* vue*
ENTRYPOINT /bin/bash /var/www/vagrantfile/environment.sh

#################################
# stage production
#################################
FROM php:8.3-apache-bullseye

RUN apt-get update > /dev/null
RUN apt-get install -y git libzip-dev libldap2-dev

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install zip ldap
RUN docker-php-ext-enable zip ldap

COPY --from=builder /var/www/vagrantfile /var/www/vagrantfile
RUN chown -R www-data:www-data /var/www/vagrantfile/
WORKDIR "/var/www/vagrantfile/"
RUN chmod -R g+w private/
RUN chmod -R g+w repository/

ENV APACHE_DOCUMENT_ROOT=/var/www/vagrantfile/dist/
ENV APACHE_PORT=8080
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/docker-php.conf
RUN sed -ri -e 's!80!${APACHE_PORT}!g' /etc/apache2/ports.conf
RUN sed -ri -e 's!80!${APACHE_PORT}!g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

EXPOSE ${APACHE_PORT}

VOLUME /var/www/vagrantfile/repository
VOLUME /var/www/vagrantfile/private

USER www-data

CMD ["/var/www/vagrantfile/environment.sh"]
