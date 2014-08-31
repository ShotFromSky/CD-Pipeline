#$1 is a system username.
#$2 is a sonarqube version.

echo ">>> Installing SonarQube $2"


JDBC_PASS=sonarproject


sudo apt-get install -y wget
wget http://dist.sonar.codehaus.org/sonar-$2.zip
sudo unzip -x sonar-3.7.4.zip -d /opt/
sudo chown -R $1:$1 /opt/sonar-$2
sudo ln -s /opt/sonar-3.7.4/bin/linux-x86-64/sonar.sh /usr/bin/sonar.sh

sudo su -
sed -i "s/sonar.jdbc.password:[[:space:]]*sonar/sonar.jdbc.password:  $JDBC_PASS/" /opt/sonar-$2/conf/sonar.properties
sed -i "s/sonar.jdbc.url:[[:space:]]*jdbc:h2:tcp:\/\/localhost:9092\/sonar/#sonar.jdbc.url:  jdbc:h2:tcp:\/\/localhost:9092\/sonar/" /opt/sonar-$2/conf/sonar.properties
sed -i "s/#sonar.jdbc.url:[[:space:]]*jdbc:postgresql:\/\/localhost\/sonar/sonar.jdbc.url:  jdbc:postgresql:\/\/localhost\/sonar\nsonar.jdbc.driverClassName:  org.postgresql.Driver\nsonar.jdbc.validationQuery:  select 1\nsonar.jdbc.schema:  public/" /opt/sonar-$2/conf/sonar.properties
su - $1

sonar.sh restart

echo '>>> Check the installation with below command'
echo '>>> psql -U sonar -d sonar -W -c "\\dt"'
echo '>>> netstat -lpn | grep 5432'
