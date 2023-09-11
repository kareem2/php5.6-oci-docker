# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Run package updates and install packages
RUN apt-get update \
    && apt-get install perl apache2 zip gzip tar -y

RUN apt update \
	&& apt install -y software-properties-common \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt install php5.6 libapache2-mod-php5.6 php5.6-curl php5.6-gd php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-xml php5.6-xmlrpc -y \
	&& a2enmod php5.6 \
	&& apt install php5.6-dev -y \
	&& apt-get install php-xml -y
	

RUN update-alternatives --set php /usr/bin/php5.6	

# Create index.php and add content to it
RUN echo "<?php phpinfo();" > /var/www/html/index.php

# Remove or rename the default index.html file
RUN rm -f /var/www/html/index.html


COPY ./oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm /opt/oracle/
COPY ./oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm /opt/oracle/

COPY instantclient-basic-linux.x64-11.2.0.4.0.zip /opt/oracle/
COPY instantclient-sdk-linux.x64-11.2.0.4.0.zip /opt/oracle/

RUN cd /opt/oracle && unzip instantclient-basic-linux.x64-11.2.0.4.0.zip && unzip /opt/oracle/instantclient-sdk-linux.x64-11.2.0.4.0.zip \
	&& ln -s /opt/oracle/instantclient_11_2/libclntsh.so.11.1 /opt/oracle/instantclient_11_2/libclntsh.so \
	&& ln -s /opt/oracle/instantclient_11_2/libocci.so.11.1 /opt/oracle/instantclient_11_2/libocci.so \
	&& echo /opt/oracle/instantclient_11_2 > /etc/ld.so.conf.d/oracle-instantclient

RUN apt-get install libaio1 \
	&& echo '/opt/oracle/instantclient_11_2/' | tee -a /etc/ld.so.conf.d/oracle-instantclient.conf \
	&& ldconfig

RUN echo "instantclient,/opt/oracle/instantclient_11_2" | pecl install oci8-2.0.12 \
	&& echo "extension = oci8.so" >> /etc/php/5.6/cli/php.ini \
	&& echo "extension = oci8.so" >> /etc/php/5.6/apache2/php.ini


# Open port 80
EXPOSE 80

# Start Apache and MySQL services.
CMD ["apachectl", "-D", "FOREGROUND"]