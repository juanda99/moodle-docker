# uses Debian 10 buster, see https://github.com/docker-library/repo-info/blob/master/repos/php/local/7.4-apache.md
FROM  php:7.4-apache
LABEL MAINTAINER juanda <juandacorreo@gmail.com>

# Moodle version without . (34 means 3.4)
ARG VERSION=34

VOLUME ["/var/moodledata"]
EXPOSE 80

# Let the container know that there is no tty JUST WHEN INSTALLING!
# Later we can run docker -ti and we need interactivity

ARG DEBIAN_FRONTEND=noninteractive

## extensions based on https://github.com/moodlehq/moodle-php-apache/blob/master/Dockerfile
COPY moodle/php-extensions.sh /tmp
RUN /tmp/php-extensions.sh


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# usefull for moodle

RUN { \
	echo 'file_uploads = On'; \
	echo 'memory_limit = 256M'; \
	echo 'upload_max_filesize = 64M'; \
	echo 'post_max_size = 64M'; \
	echo 'max_execution_time = 600'; \
} > /usr/local/etc/php/conf.d/uploads.ini

RUN a2enmod rewrite expires

RUN	echo "Installing moodle" && \
		# better tgz file, smaller and we can remove parent directory with --strip option so we don't have to move folder, time saving!!!
		curl https://download.moodle.org/download.php/direct/stable${VERSION}/moodle-latest-${VERSION}.tgz -o /var/www/html/moodle-latest.tgz  && \
		cd /var/www/html && tar -xf moodle-latest.tgz --strip 1 && \
		mkdir /var/www/moodledata && chown www-data:www-data /var/www/moodledata  && \
		chown -R www-data:www-data -R /var/www/html && \
		rm /var/www/html/moodle-latest.tgz

# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp

COPY ./moodle/moodle-config.php /moodle/config.php
