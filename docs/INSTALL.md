# Installing PUPIL

These are the basic steps required to get PUPIL up and running:

* Install Java (JDK 8 preferably)
* Install Tomcat (version 8 works)
* Install MySql (any modern version)
* Create a mysql database
* Populate the database using the setup_db.sql script
* Edit and move the pupil webapp configuration to the appropriate Tomcat directory
* Start pupil
* Create a teacher
* Login in and test that everything works

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

Currently PUPIL is written for MySQL, but it's possible that, 
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

You need to create a database and configure access to it. You can choose
database name, database user and database password freely, but remember
these. You will need to insert them in a configuration file later.

The following is an example only, for creating a database called "pupil",
with a user "pupil" that has a password "pupil". This is how the default
configuration is written, so if you only want to test things on your 
own computer this might suffice. But for production environments you 
should be more creative with at least the password. 

Start a mysql root prompt (see mysql docs on how to do this). Then run:

    CREATE DATABASE pupil;
    GRANT ALL ON pupil.* TO pupil@'localhost' IDENTIFIED by 'pupil';
    FLUSH PRIVILEGES;

## Populate the database

In the SETUP directory, there is a file called setup_db.sql. This 
contains the basic definition for the initial database. 

### Running the setup script on ubuntu

On ubuntu, run:

    mysql -u pupil --password=pupil pupil < setup_db.sql

(but replace the first "pupil" with the username you used above, the 
second "pupil" with your password and the third "pupil" with the name 
of your database)

### Running the setup script on windows

to be written

## Edit the webapp configuration

This step consist of two parts: Editing the database and admin settings
in "WEB-INF/web.xml" and writing a configuration file for Tomcat so that
it can find the web application.

For the first part: edit the file WEB-INF/web.xml. Find and change the
admin username and passwords. You can set whatever you want here, this is
only used for managing teachers. Also change all relevant database 
settings. If you named your database name/user/password "pupil", you can 
keep the existing values.

For the second part:
In the SETUP directory you will find a sample configuration file for the
webapp ("pupil.xml.sample"). You will need to edit this and set docBase
to point at the PUPIL directory from the zip file. You then need to
move/rename it to the configurations directory for tomcat. 

### Installing the config on ubuntu

On ubuntu the file should end up as /etc/tomcat8/Catalina/localhost/pupil.xml.

### Installing the config on windows

to be written

## Starting PUPIL

Tomcat will most likely need a restart in order to find the configuration.
So restart Tomcat and then access the manager which will most likely be
available at:

http://127.0.0.1:8080/manager/html

The login and password for the manager will need to be set in the Tomcat
configuration before you can access this page. You can find instructions
on how to do this at

https://tomcat.apache.org/tomcat-8.0-doc/manager-howto.html#Configuring_Manager_Application_Access

But once you have entered the manager page, you should see an entry 
"/pupil". If not, you have most likely missed something in the "Edit
webapp configuration" step. 

If the entry is there, click on it and you should arrive at the
login page for PUPIL.

## Create a teacher

If everything worked thus far, you should now be able to create a teacher
login. If pupil is on your local computer, navigate to:

http://127.0.0.1/pupil/admin.jsp

You will be asked for the admin username and password, which you entered
in the web.xml file above. 

Here you can find some self-explanatory fields for creating and changing
teachers. 

## Login as a teacher 

You should now have a configured system. Navigate to:

http://127.0.0.1/pupil

.. and login as a teacher. 

## From here

The docs are somewhat outdated, but should be relevant for the most part.
You can [find the PDF documentation here](old_user_manual.pdf).

