# PUPIL

PUPIL

## Building

To build PUPIL you need to download the dependencies and use "ant"
to compile the various components. 

Each build step will create files indirectory dist/PUPIL. This is a web 
application suitable for (for example) Tomcat. 

### Requirements

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

The backend is written in java, and a JDK version of at least 1.6 is 
needed. In principle any modern JDK should thus work. 

The build system is "ant", which needs to be installed and configured 
properly. See http://ant.apache.org/

### Downloading dependencies

There is a number of JAR files which need to be placed in "lib/" before
being able to perform the java build step. 

The easiest way to acquire these are via:

    ant download-ivy
    ant dependencies

Or if you for some reason need to do this manually, you can find detailed
instructions in the [lib README](lib/README.md).

### Building everything in one step 

To compile a viable webapp (after dependencies have been downloaded) in 
"dist/PUPIL/" run:

    ant dist

This will build the flash frontend, the java backend, copy dependencies, 
create an SQL setup script etc. 

### Building components separately

If you want to (re-)build a specific part, you can use one of the 
the following ant tasks:

* pupil-flash -- will build the flash frontend
* pupil-java -- will build the java backend
* mergesql -- will construct a SQL database setup file

