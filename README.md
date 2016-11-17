# PUPIL
PUPIL

## Building

To build PUPIL you need to build a) the flash frontend and b) the java 
servlet backend.

Each build step will create files indirectory dist/PUPIL. This is a web 
application suitable for (for example) Tomcat. 

### Building the flash frontend

The frontend is written as a Flex 3.x flash application. To build these
things, you need the Flex SDK from adobe. At the time of writing this, 
you can find the SDK at 

    http://www.adobe.com/devnet/flex/flex-sdk-download-all.html

It is possible a 4.x SDK works, but if you run into trouble, use one of
the 3.x SDKs available. 

To protect your sanity, please stay away from trying to install the 
apache version of Flex. It requires several separately downloaded
proprietary binary blobs, and at the time of writing these the links 
to the blobs lead to non-existent web pages.

There is a Makefile available in flash-src. It will automate the build
and install process, but it presupposes that "mxmlc" is available in 
PATH. You will find "mxmlc" in the "bin" subdir of the SDK zip you 
downloaded from adobe, so add this dir to your PATH variable. 

To build the flash frontend run:

    make 

To "install" it to the folder under dist/ where the application is 
assembled, run:

    make dist

To build manually (for example on windows), run

    mxmlc.exe teacher.as
    mxmlc.exe reaction.as

Create a new directory dist/PUPIL/flash. Copy everything from 
static-files to this directory. Copy the .swf files to the directory.

### Building the servlet backend


