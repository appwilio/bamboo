FROM ubuntu:16.04

#ENV BAMBOO_INSTALL=/home/bamboo/install
#ENV BAMBOO_HOME=/home/bamboo/home

EXPOSE 8085

RUN apt-get update -y
RUN apt-get install -y -f -q locales
#ADD repo for PHP7.1
RUN locale-gen en_US.UTF-8 \
	&& export LANG=en_US.UTF-8 \
	&& apt-get install -y -f -q software-properties-common python-software-properties \
	&& locale -a \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt-get update -y

#Install software neneded for installation
RUN apt-get install -y -f -q curl
RUN apt-get install -y -f -q wget
RUN apt-get install -y -f -q zip

#Install and config mysql
RUN apt-get update --fix-missing \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y -f -q install mysql-server-5.7 \
	&& echo "[mysqld]" >> /etc/mysql/my.cnf \
	&& echo "character-set-server = utf8" >> /etc/mysql/my.cnf \
	&& echo "collation-server = utf8_bin" >> /etc/mysql/my.cnf \
	&& echo "innodb_log_file_size=64MB" >> /etc/mysql/my.cnf

#Install bamboo needs
RUN apt-get install -y -f -q default-jdk

#Install jmeter for load testing
RUN mkdir -p "/usr/share/jmeter/" \
	&& cd /tmp \
	&& wget -qc http://ftp.ps.pl/pub/apache/jmeter/binaries/apache-jmeter-3.1.tgz \
	&& tar -xzf apache-jmeter-3.1.tgz --directory "/usr/share/jmeter" --strip-components=1 --no-same-owner \
	&& ln -s /usr/share/jmeter/bin/jmeter /usr/bin/jmeter

#Install git for pull code from repository
RUN apt-get install -y -f -q git

#Install PHP to get projects works
RUN apt-get install -y -f -q php7.1 \
	#For composer install requirements
	&& apt-get install -y -f -q php7.1-curl \
	&& apt-get install -y -f -q php7.1-mysql \
	&& apt-get install -y -f -q php7.1-mbstring \
	&& apt-get install -y -f -q php7.1-xml \
	&& apt-get install -y -f -q php7.1-zip \
	&& echo "memory_limit = 521M" >> /etc/php/7.1/cli/conf.d/fortest.ini

#Install composer
RUN cd /tmp \
	&& curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer global require hirak/prestissimo

#Install PHPUnit to run tests
RUN wget -q "https://phar.phpunit.de/phpunit.phar" \
	&& mv phpunit.phar /usr/local/bin/phpunit \
	&& chmod +x /usr/local/bin/phpunit 

#RUN service mysql start \
#	&& mysql -u root -e "CREATE DATABASE IF NOT EXISTS bamboo CHARACTER SET utf8 COLLATE utf8_bin;" \
#	&& mysql -u root -e "CREATE USER IF NOT EXISTS 'bamboo'@'localhost' IDENTIFIED BY '123456';" \
#	&& mysql -u root -e "GRANT all ON bamboo.* TO 'bamboo'@'localhost';"
#RUN mkdir -p "${BAMBOO_INSTALL}" \
#	&& mkdir -p "${BAMBOO_HOME}" \
#	&& curl -Ls "https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.15.3.tar.gz" | tar -xz --directory  "${BAMBOO_INSTALL}" --strip-components=1 --no-same-owner \
#	&& curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz" | tar -xz --directory "${BAMBOO_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar" \
#	&& sed --in-place 's/#BAMBOO_HOME=""/BAMBOO_HOME="\/home\/bamboo\/home"/g' "${BAMBOO_INSTALL}/bin/setenv.sh"
 
#VOLUME ["/var/lib/mysql"]
#Adding run script to startup and config mysql and bamboo
ADD start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
