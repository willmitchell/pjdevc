This script downloads various archives and helps you build your shell environment.
It is intended to support Java work at my job, but it may be useful for others.

Prerequisites:

1. Java SE. Make sure JAVA_HOME is set.

  http://www.oracle.com/technetwork/java/javase/downloads/index.html
	 
2. A unix-like OS (Linux, OSX), or, on Windows: You need msysgit.  Cygwin may or may not work.

  http://code.google.com/p/msysgit/

Steps:

1. git clone git://github.com/willmitchell/pjdevc.git

2. cd pjdevc

3. ./pjdevc.pl

4. Modify your ~/.profile, so that it contains something like:

	if [ -f ~/pjdevc/vars.sh ] ; then . ~/pjdevc/vars.sh ; fi
	
5. Launch a new terminal window.  Your path should be all set, so you can run stuff like grails right away.

6. Do your day job.

Will Mitchell
Noblis