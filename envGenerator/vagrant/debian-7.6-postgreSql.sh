#$1 is a system username.
#$2 is a PostgreSql server version.

DB_USER=sonar
DB_NAME=sonar
DB_PASSWORD=sonarproject

echo ">>> Installing PostgreSQL Server $2"

sudo apt-get install -y postgresql

sudo su -
sed -i "s/postgres[[:space:]]*peer/postgres  trust/" /etc/postgresql/$2/main/pg_hba.conf
# Change peer authentication is now using md5 authentication.
sed -i "s/all[[:space:]]*peer/all  md5/g" /etc/postgresql/$2/main/pg_hba.conf
# Open remote access port to any URL accessing $DB_NAME with $DB_USER with md5 authentication   
echo "host  $DB_USER  $DB_NAME  0.0.0.0/0  md5" | tee -a /etc/postgresql/$2/main/pg_hba.conf
sed -i "s/#listen_addresses[[:space:]]*=[[:space:]]*'localhost'/listen_addresses = 'localhost'\nlisten_addresses = '*'/" /etc/postgresql/$2/main/postgresql.conf
su - $1

sudo service postgresql restart 

sudo su - postgres
createuser -U postgres -D -R -S $DB_USER
createdb -U postgres -E UTF8 -O $DB_NAME $DB_USER
psql -U postgres -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
psql -U postgres -c "GRANT ALL ON DATABASE $DB_NAME TO $DB_USER;"
su - $1

sudo su -
sed -i "s/postgres[[:space:]]*trust/postgres  peer/" /etc/postgresql/9.1/main/pg_hba.conf
su - $1

sudo service postgresql restart

echo '>>> Check the installation with below command'
echo '>>> psql -U sonar -d sonar -W -c "SELECT 1;"'
