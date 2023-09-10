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
	&& apt install php-dev php-pear -y \
	&& apt-get install php-xml -y
	

RUN update-alternatives --set php /usr/bin/php5.6	

# Create index.php and add content to it
RUN echo "<?php phpinfo();" > /var/www/html/index.php

# Remove or rename the default index.html file
RUN rm -f /var/www/html/index.html


COPY ./oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm /oracle/
COPY ./oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm /oracle/



# Open port 80
EXPOSE 80

# Start Apache and MySQL services.
CMD ["apachectl", "-D", "FOREGROUND"]



# apt-get install alien -y
# alien -d oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
# alien -d oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm

# dpkg -i oracle-instantclient11.2-basic_11.2.0.4.0-2_amd64.deb
# dpkg -i oracle-instantclient11.2-devel_11.2.0.4.0-2_amd64.deb


# export ORACLE_HOME=/usr/lib/oracle/11.2/client64
# export LD_LIBRARY_PATH=$ORACLE_HOME/lib
# ldconfig