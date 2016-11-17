# Dependencies

Place the required JAR files here. They will be automatically used in
the build process.

You can populate this directory with one of two available methods. 
Either you can download the dependencies manually and copy the relevant
JAR files to the directory. 

Or you can use Ivy to do it all automatically. In which case you need
to install Ivy. 

## Using Ivy

Ivy

## Downloading manually

The following dependencies need to be fulfilled somehow

### Commons FileUpload

This is a plan JAR file, which is available at

https://commons.apache.org/proper/commons-fileupload/download_fileupload.cgi

### Log4j

The code uses the log4j 1.x api. You download either an 1.2 release or 
download a 2.x release with a compatibility wrapper. The recommended
approach is the latter. Log4j 2.x is available here:

http://logging.apache.org/log4j/2.x/download.html

From the downloadable, you need these JARs:

* log4j-api-2.x.jar
* log4j-core-2.x.jar
* log4j-1.2-api-2.x.jar

