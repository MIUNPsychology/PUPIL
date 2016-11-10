#!/bin/bash

PWD=`pwd`

PLIB=$PWD/../../lib
MAIN=/usr/share/java

CLASSPATH=.

CLASSPATH=$CLASSPATH:$MAIN/servlet-api-2.5.jar

for file in $PLIB/*.jar ; do
	CLASSPATH=$CLASSPATH:$file
done

export CLASSPATH
