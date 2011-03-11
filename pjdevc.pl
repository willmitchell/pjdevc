#!/usr/bin/env perl 
# Written by Will Mitchell
#
# For the record, I prefer Groovy, Ruby, or even Python over Perl, which I do not dislike.  
# Perl is fine.  It is also part of the standard distro's I need my colleagues to be able
# to bootstrap a java development environment on:
# 1. OSX
# 2. Linux
# 3. Windows with msysgit preinstalled
#
# This script downloads a set of java jars, puts them in some standard folders and generates
# a set of bash shell script declarations that you can reference from your ~/.profile.


use warnings;
use Cwd;

$db = <<END;
ivy|IVY_HOME|http://apache.mirrors.tds.net//ant/ivy/2.2.0/apache-ivy-2.2.0-bin.zip|2.2.0
gradle|GRADLE_HOME|Http://gradle.artifactoryonline.com/gradle/distributions/gradle-1.0-milestone-1-all.zip|1.0-m1
END

my @lines = split /\n/, $db;

open(VF,">vars.sh") or die;

sub ex{
	$cmd=$_[0] or die;
	print "Executing: ",$cmd, "\n";
	my $rval = system($cmd);	
	if ($rval!=0) {
		print "Warning, return value: $rval\n";
	}
}  

my @pdirs=();

my $origDir=getcwd;
my $libDir = "lib";

if (-e $libDir){
	ex("rm -fr $origDir/$libDir");
	unlink $libDir;
}
mkdir $libDir or die;
chdir $libDir or die;
$libDir = getcwd;


foreach $line (@lines) {
	chomp $line;
	chdir $libDir or die;
	my ($name, $evname, $url, $version) = split (/\|/, $line);
	my $dirname="$name-$version";
	my $fullDirPath="$libDir/$dirname";
	print VF "$evname=$fullDirPath\n";
	push(@pdirs,"$fullDirPath/bin");
	
	if (-e $dirname) {
		print "Skipping $name because directory exists: $dirname\n";		
	}else {
		mkdir $dirname or die;
		chdir $dirname or die;
		my $cwd1=getcwd;
		print "Getting ", $name, " at url: $url\n";
		$of="of.zip";
		ex("curl $url --output $of");
		die "of.zip not there" unless -e $of;
		ex("unzip $of");
		ex("rm -f $of");
		
		@files = glob ("*");
		$fcount = scalar @files;
		print "files in dir: \n", scalar @files, " contents: ",@files.join(",");
		if ($fcount==1){
			$hold="$origDir/hold";
			ex("rm -fr $hold");
			ex("mkdir $hold");
			$deep="$cwd1/$files[0]";
			print "Source folder is: $deep\n";
			ex("mv $deep/* $hold");
			ex("rm -fr $deep");
			ex("mv $hold/* $cwd1");
			ex("rm -fr $hold");
		}
	}
}
$p=join(":",@pdirs);
print VF "PATH=$p:",'$',"PATH";
close VF;