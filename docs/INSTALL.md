# Installing PUPIL

These are the basic steps required to get PUPIL up and running:

* Install Tomcat (version 8 works)
* Install MySql (any modern version)
* Create a mysql database
* Populate the database using the setup_db.sql script
* Edit and move the pupil webapp configuration to the appropriate Tomcat directory

## Install Tomcat

to be written

## Install MySql

to be written

## Create a mysql database

to be written

## Popuplate the database

to be written

## Edit the webapp configuration

In the SETUP directory you will find a sample configuration file for the
webapp ("pupil.xml.sample"). You will need to edit this and set docBase
to point at the PUPIL directory from the zip file. You then need to
move/rename it to the configurations directory for tomcat. On ubuntu 
the file should end up as /etc/tomcat8/Catalina/localhost/pupil.xml.

