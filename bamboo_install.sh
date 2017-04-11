BAMBOO_INSTALL="/home/bamboo/install"
BAMBOO_HOME="/home/bamboo/home"
echo "Making dirs $BAMBOO_INSTALL; $BAMBOO_HOME"
mkdir -p "$BAMBOO_INSTALL"
mkdir -p "$BAMBOO_HOME"
echo "Downloading Bamboo"
curl -L "https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.15.3.tar.gz" | \
	tar -xz --directory  "$BAMBOO_INSTALL" --strip-components=1 --no-same-owner
echo "Downloading mysql-connector"
curl -L "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz" | \
	tar -xz --directory "$BAMBOO_INSTALL/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar"
echo "Setting BAMBOO_HOME in setenv.sh"
sed --in-place 's/#BAMBOO_HOME=""/BAMBOO_HOME="\/home\/bamboo\/home"/g' "$BAMBOO_INSTALL/bin/setenv.sh"
