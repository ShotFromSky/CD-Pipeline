SONAR_VERS="3.7.4"
POSTGRESQL_VER="9.1"
JDK_VER="7"

sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y bash-completion
sudo apt-get install -y zip
sudo apt-get install -y vim
source ~/.bashrc

sudo su -
	echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
	echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
	#echo "deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/" | tee -a /etc/apt/sources.list
	apt-get update
su - sky

sudo apt-get install -y postgresql
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install -y oracle-jdk7-installer


wget http://dist.sonar.codehaus.org/sonar-3.7.4.zip
sudo unzip -x sonar-3.7.4.zip -d /opt/
sudo chown -R sky:sky /opt/sonar-3.7.4
sudo ln -s /opt/sonar-3.7.4/bin/linux-x86-64/sonar.sh /usr/bin/sonar.sh

sudo su -
sed -i "s/postgres[[:space:]]*peer/postgres  trust/" /etc/postgresql/9.1/main/pg_hba.conf
sed -i "s/all[[:space:]]*peer/all  md5/g" /etc/postgresql/9.1/main/pg_hba.conf
echo "host  sonar  sonar  0.0.0.0/0  md5" | tee -a /etc/postgresql/9.1/main/pg_hba.conf
sed -i "s/#listen_addresses[[:space:]]*=[[:space:]]*'localhost'/listen_addresses = 'localhost'\nlisten_addresses = '*'/" /etc/postgresql/9.1/main/postgresql.conf
su - sky

sudo service postgresql restart 
sudo su - postgres
createuser -U postgres -D -R -S sonar
createdb -U postgres -E UTF8 -O sonar sonar
psql -U postgres -c "ALTER USER sonar WITH PASSWORD 'sonarproject';"
psql -U postgres -c "GRANT ALL ON DATABASE sonar TO sonar;"
psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgresadmin';"
su - sky

sudo su -
sed -i "s/postgres[[:space:]]*trust/postgres  peer/" /etc/postgresql/9.1/main/pg_hba.conf
sed -i "s/sonar.jdbc.password:[[:space:]]*sonar/sonar.jdbc.password:  sonarproject/" /opt/sonar-3.7.4/conf/sonar.properties
sed -i "s/sonar.jdbc.url:[[:space:]]*jdbc:h2:tcp:\/\/localhost:9092\/sonar/#sonar.jdbc.url:  jdbc:h2:tcp:\/\/localhost:9092\/sonar/" /opt/sonar-3.7.4/conf/sonar.properties
sed -i "s/#sonar.jdbc.url:[[:space:]]*jdbc:postgresql:\/\/localhost\/sonar/sonar.jdbc.url:  jdbc:postgresql:\/\/localhost\/sonar\nsonar.jdbc.driverClassName:  org.postgresql.Driver\nsonar.jdbc.validationQuery:  select 1\nsonar.jdbc.schema:  public/" /opt/sonar-3.7.4/conf/sonar.properties
su - sky

sudo service postgresql restart
sonar.sh restart
#psql -U sonar -d sonar -W -c "SELECT 1;"
#psql -U sonar -d sonar -W -c "\\dt"
#netstat -lpn | grep 5432

# change 
# vim /etc/postgresql/9.1/main/pg_hba.conf
# Change  
# local   all             postgres            peer
# To
# local   all             postgres            md5
# sudo service postgresql restart
# psql -U sonar -d sonar -W -c "SELECT 1;"

# add below lines in the /opt/sonar/conf/sonar.properties 
# sonar.jdbc.username=sonar
# sonar.jdbc.password=sonarproject
# sonar.jdbc.url=jdbc:postgresql://localhost/sonar
# sonar.jdbc.driverClassName=org.postgresql.Driver
# sonar.jdbc.validationQuery=select 1
# sonar.jdbc.schema=public

# sonar.jdbc.maxActive=20
# sonar.jdbc.maxIdle=5
# sonar.jdbc.minIdle=2
# sonar.jdbc.maxWait=5000
# sonar.jdbc.minEvictableIdleTimeMillis=600000
# sonar.jdbc.timeBetweenEvictionRunsMillis=30000

# sonar.sh restart
# psql -U sonar -d sonar -W -c "\\dt"

