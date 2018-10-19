#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Build packages will be added during the build, but will be removed at the end.
BUILD_PACKAGES="gettext gnupg libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
  libldap2-dev libmariadbclient-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev \
  unixodbc-dev zlib1g-dev"

# Packages for MySQL.
#PACKAGES_MYMARIA="libmariadbclient18"
PACKAGES_MYMARIA="mysql-client"

# Packages for other Moodle runtime dependencies.
PACKAGES_RUNTIME="ghostscript libaio1 libcurl3 libgss3 libicu57 libmcrypt-dev libxml2 libxslt1.1 locales sassc unzip unixodbc"

apt-get update
apt-get install -y --no-install-recommends \
    $BUILD_PACKAGES \
    $PACKAGES_MYMARIA \
    $PACKAGES_RUNTIME

# Generate the locales configuration
echo 'Generating locales..'
echo 'es_ES.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

echo "Installing php extensions"

docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    mysqli \
    soap \
    xmlrpc \
    zip 

  # opcache \ Not used, to prevent segmentation fault (11), possible coredump in /etc/apache2

# Keep our image size down..
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
