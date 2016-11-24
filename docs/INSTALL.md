# Installing PUPIL

These are the basic steps required to get PUPIL up and running:

* Install Java (JDK 8 preferably)
* Install Tomcat (version 8 works)
* Install MySql (any modern version)
* Create a mysql database
* Populate the database using the setup_db.sql script
* Edit and move the pupil webapp configuration to the appropriate Tomcat directory

## Install Java

You will need a modern Java. In theory JDK 9 could work, but it is known
to be buggy on, for example, ubuntu 16.04. So out of convenience, you 
might want to stick with JDK 8. 

### Installing on ubuntu

You can use OpenJDK, which is available via apt. Run:

    sudo apt-get install openjdk-8-jdk

If you know you have another JDK/JRE installed (if you don't know, it's
unlikely), you might want to run:

    sudo update-java-alternatives

But this step is probably unnecessary.

### Installing on windows

You can download java here:

http://www.oracle.com/technetwork/java/javase/downloads/index.html

Note that you want "JDK", not "JRE". It's superfluous to get the 
big package with NetBeans included, but if you want to play around
with it, it doesn't hurt. 

## Install Tomcat

If you need to download tomcat manually (which you will need for
windows), you can find it here:

http://tomcat.apache.org/download-80.cgi

It is possible a later version than 8.0 will work, but 8.0 is 
known to work.

### Installing on ubuntu

Tomcat is readily available via apt. Run:

    sudo apt-get install tomcat8 tomcat8-manager tomcat8-admin

This should get Tomcat up and running on port 8080.

### Installing on Windows

The documentation on how to get Tomcat working on windows is
available here:

http://tomcat.apache.org/tomcat-8.0-doc/setup.html#Windows

## Install MySQL

Currently PUPIL is hard-coded to use MySQL, but it's possible that, 
for example, MariaDB is compatible enough to work anyway. But out of 
convenience, stick with MySQL. Any modern version should work.

### Installing on ubuntu

MySQL is available via apt. Run:

    sudo apt-get install mysql-server

...and follow the instructions. No particular configuration is needed, 
but you will need to remember what root password you are setting for 
it. 

### Installing on windows

MySQL is available for download at:

http://dev.mysql.com/downloads/mysql/

The installation instructions are available here:

http://dev.mysql.com/doc/refman/5.7/en/windows-installation.html

## Create a mysql database

Currently all values are hard-coded, which is ugly. This might change
in the future. But in practice, you will now need to create a database
called "pupil" with a user called "pupil" and a password "pupil". 

Start a mysql root prompt (see mysql docs on how to do this). Then run:

    CREATE DATABASE pupil;
    GRANT ALL ON pupil.* TO pupil@'localhost' IDENTIFIED by 'pupil';
    FLUSH PRIVILEGES;

## Popuplate the database

In the SETUP directory, there is a file called setup_db.sql. This 
contains the basic definition for the initial database. 

### Running the setup script on ubuntu

On ubuntu, run:

    mysql -u pupil --password=pupil pupil < setup_db.sql

### Running the setup script on windows

to be written

## Edit the webapp configuration

In the SETUP directory you will find a sample configuration file for the
webapp ("pupil.xml.sample"). You will need to edit this and set docBase
to point at the PUPIL directory from the zip file. You then need to
move/rename it to the configurations directory for tomcat. On ubuntu 
the file should end up as /etc/tomcat8/Catalina/localhost/pupil.xml.

