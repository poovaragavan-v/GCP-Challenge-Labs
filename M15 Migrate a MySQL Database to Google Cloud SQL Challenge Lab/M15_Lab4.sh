# Task 1: Create a new Cloud SQL instance

export ZONE=europe-west1-d
gcloud sql instances create wordpress \
  --tier=db-n1-standard-1 \
  --region=europe-west1 \
  --database-version=MYSQL_5_7 \
  --root-password=Password1*

# Task 2: Configure the new database
    ##You already created the database during instance creation.
    ##So there's no specific configuration needed here.

# Task 3: Perform a database dump and import the data

MYSQLIP=$(gcloud sql instances describe wordpress --format="value(ipAddresses.ipAddress)")
export MYSQL_PWD=Password1*

# Dump the local MySQL database
sudo mysqldump -u root -p Password1* wordpress > wordpress_backup.sql

# Import the data into Cloud SQL
mysql --host=$MYSQLIP --user=root -pPassword1* --verbose wordpress < wordpress_backup.sql

# Task 4: Reconfigure the WordPress installation

# Get the external IP of the Cloud SQL instance
EXTERNAL_IP=$(gcloud sql instances describe wordpress --format="value(ipAddresses[0].ipAddress)")

# Update wp-config.php to point to Cloud SQL
sudo sed -i "s/define('DB_HOST', 'localhost')/define('DB_HOST', '$EXTERNAL_IP')/" /var/www/html/wordpress/wp-config.php

# Task 5: Validate and troubleshoot

    ## After completing the above steps, 
    ## you should validate the WordPress blog to ensure it's functioning correctly 
    ## with the new Cloud SQL database. 
    ## You can do this by accessing the blog in a web browser and 
    ## checking if all functionalities work as expected.