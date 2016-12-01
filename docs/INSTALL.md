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
unlikely. In most cases the following step is unnecessary), you might want to run:

    sudo update-java-alternatives

### Installing on windows

You can download java here:

http://www.oracle.com/technetwork/java/javase/downloads/index.html

Note that you want "JDK", not "JRE". It's superfluous to get the 
big package with NetBeans included, but if you want to play around
with it, it doesn't hurt. 

You can accept all the default suggestions in the installer and just click "next".

## Install Tomcat

You will want to download tomcat 8.x. It is possible a later version than 8.0 will work, but 8.0 is 
known to work.

### Installing on ubuntu

Tomcat is readily available via apt. Run:

    sudo apt-get install tomcat8 tomcat8-manager tomcat8-admin

This should get Tomcat up and running on port 8080.

### Installing on Windows

Download tomcat from:

http://tomcat.apache.org/download-80.cgi

The installation steps are in summary as follows:

* Download the "32/64 bit windows service installer" from the download page
* Execute and install
    * On the "choose components" step, also check "host manager"
    * On the "configuration" step, be sure to enter user/password for an administrator account, and remember these
* On the last step you can choose to start the service. In the future you will have a "monitor tomcat" entry on your start menu, where you can start and stop tomcat.

Unless you changed something, tomcat should now run on port 8080.

## Install MySQL and create a database

Currently PUPIL is written for MySQL, but it's possible that, 
for example, MariaDB is compatible enough to work anyway. But out of 
convenience, stick with MySQL. Any modern version should work.

### Installing on ubuntu

MySQL is available via apt. Run:

    sudo apt-get install mysql-server

...and follow the instructions. No particular configuration is needed, 
but you will need to remember what root password you are setting for 
it. 

Start a mysql root prompt:

    mysql -u root -p mysql

Then, on the prompt, run:

    CREATE DATABASE pupil;
    GRANT ALL ON pupil.* TO pupil@'localhost' IDENTIFIED by 'pupil';
    FLUSH PRIVILEGES;

This is an example only, for creating a database called "pupil",
with a user "pupil" that has a password "pupil". This is how the default
configuration is written, so if you only want to test things on your 
own computer this might suffice. But for production environments you 
should be more creative with at least the password. 


### Installing on windows

MySQL is available for download at:

http://dev.mysql.com/downloads/mysql/

You want the windows msi installer. Ignore the nag about registering (there is a link for proceeding with the download at the bottom of the page). 

In the installer:

* For type, choose "Custom".
* On "Select products and features", move almost all components from the right side to the left (there is a green arrow to click). On the right side you should only have:
    * MySQL server
    * MySQL workbench
    * MySQL utilities
* On "type and networking", you can accept the defaults unless you know what you are doing. If you intend the installation to be for a production server, change "Config type" to "Server machine"
* On "accounts and roles":
    * Enter and remember an administrative password
    * Add a new user "pupil" and set (and remember) a password for that user
* For the rest of the steps in the installer, you can accept the defaults

You should now start "mysql workbench" (the installer allows you to do this as the final step). In the workbench do the following

* Click "local instance", and log in as admin
* Click "create new schema in the connected instance" (it's the fourth icon from the left in the toolbar) (for some reason "database" is called "schema" in mysql workbench, but "database" on a mysql prompt... Why this is so, I guess you'll have to ask a mysql dev)
* Enter "pupil" as its name, then click "apply", "apply" and "finish". 
* You should now have a "pupil" entry under "schemas" in the bottom of the hierarchy to the left in the window. 
* Right-click the "pupil" schema and select "set as default". You will get no feedback, but the entry should now be listed boldfaced.

## Populate the database

In the SETUP directory, there is a file called setup_db.sql. This contains the basic definition for the initial database. 

### Running the setup script on ubuntu

On ubuntu, run:

    mysql -u pupil --password=pupil pupil < setup_db.sql

(but replace the first "pupil" with the username you used above, the 
second "pupil" with your password and the third "pupil" with the name 
of your database)

### Running the setup script on windows

In mysql workbench:

* open the "file" menu and "open sql script". 
* Browse to the "setup_db.sql" script in the SETUP folder
* Execute the script (it's the icon looking like a lightning bolt)

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

On windows the file should (probably) end up as C:\Program Files\Apache Software Foundation\Tomcat 8.5\conf\Catalina\localhost\pupil.xml

... but this will depend on where you installed tomcat, and might look slightly different depending on windows version and locale. 

So the basic steps will (for example) be:

* Rename the pupil.xml.sample file to pupil.xml
* Edit it with an appropriate text editor (wordpad should work, notepad might run into trouble with line endings)
* change docBase to point at where you unzipped the zip file, for example "c:\PUPIL"

## Starting PUPIL

Tomcat will most likely need a restart in order to find the configuration.
So restart Tomcat and then access the manager which will most likely be
available at:

http://127.0.0.1:8080/manager/html

On windows you will already have set login and password for the manager in a configuration step above.
On ubuntu, you will need to edit /etc/tomcat8/tomcat-users.xml to add a login for the manager, see

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

