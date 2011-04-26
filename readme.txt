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

3. perl pjdevc.pl

4u. On Unix/OSX, modify your ~/.profile, so that it contains something like:

	. ~/pjdevc/vars.sh
	
4w.	On Windows, create a new shell window (cmd.exe) and run pjdevc/vars.bat.  Note
that this way of using pjdevc only affects the current cmd.exe window.  It DOES NOT 
modify your control panel/global environment variable settings.  Pjdevc settings 
just supersede those in the global environment.
	
5. You can now run griffon, grails, gradle, maven, etc right from the command prompt.

Will Mitchell
Noblis