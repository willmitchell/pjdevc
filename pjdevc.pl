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

#
# Hardly a database, but these are the files, names, urls, versions, etc for the things we want to manage.
#
$db = <<END;
gradle|GRADLE_HOME|Http://gradle.artifactoryonline.com/gradle/distributions/gradle-1.0-milestone-3-all.zip|1.0-m3
groovy|GROOVY_HOME|http://dist.groovy.codehaus.org/distributions/groovy-binary-1.7.10.zip|1.7.10
grails|GRAILS_HOME|http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-1.3.7.zip|1.3.7
griffon|GRIFFON_HOME|http://dist.codehaus.org/griffon/griffon/0.9.x/griffon-0.9.2-bin.zip|0.9.2
ivy|IVY_HOME|http://mirror.cc.columbia.edu/pub/software/apache/ant/ivy/2.2.0/apache-ivy-2.2.0-bin.zip|2.2.0
ant|ANT_HOME|http://www.eng.lsu.edu/mirrors/apache//ant/binaries/apache-ant-1.8.2-bin.zip|1.8.2
maven|MAVEN_HOME|http://www.eng.lsu.edu/mirrors/apache//maven/binaries/apache-maven-3.0.3-bin.zip|3.0.3
hudson|HUDSON_HOME|http://java.net/projects/hudson/downloads/download/war/hudson-2.0.1.war|2.0.2
END

my @lines = split /\n/, $db;

# 
# In your .profile, put something like:
#
# if [ -f ~/pjdevc/vars.sh ] ; then . ~/pjdevc/vars.sh ; fi
#
open(VF,">vars.sh") or die;
open(BF,">vars.bat") or die;

# print stuff out and warn if nonzero rval
sub ex{
	$cmd=$_[0] or die;
	print "Executing: ",$cmd, "\n";
	my $rval = system($cmd);	
	if ($rval!=0) {
		print "### Warning, return value: $rval\n";
	}
}  

#
# All downloaded tools are kept in a "lib" folder.
#
my @pdirs=();
my @bdirs=();
my $origDir=getcwd;
my $libDir = "lib";

# if (-e $libDir){
# 	ex("rm -fr $origDir/$libDir");
# 	unlink $libDir;
# }

mkdir $libDir;
chdir $libDir or die;
$libDir = getcwd;

my $unzip = "unzip";
my $osname = $^O;
my $windows=0;
my $eol="\n";
if( $osname eq 'msys' ){{
	$windows = 1;
	$eol = "\r\n";
	$unzip = "jar xvf";
}}

sub portable_envarify{
	$p=$_[0] or die;
#	print "Pathifying ",$p, "\n";
	if ($windows){
		$p =~ s|^/(\w)/|$1:/|;
		$p =~ s|/|\\\\|g;
	}
#	print "platform envar path: $p\n";
	return $p;
}

sub portable_enbatify{
	$p=$_[0] or die;
#	print "Batifying ",$p, "\n";
	$p =~ s|^/(\w)/|$1:/|;
	$p =~ s|/|\\|g;
#	print "platform bat path: $p\n";
	return $p;
}

foreach $line (@lines) {
	chomp $line;
	chdir $libDir or die;
	my ($name, $evname, $url, $version) = split (/\|/, $line);
	my $dirname="$name-$version";
	my $fullDirPath="$libDir/$dirname";
	my $envarPath = portable_envarify($fullDirPath);
	my $envarBatPath = portable_enbatify($fullDirPath);
	print VF "export $evname=$envarPath$eol";
	print BF "set $evname=$envarBatPath$eol";
	push(@pdirs,"$fullDirPath/bin");
	push(@bdirs,"$envarBatPath\\bin");
	
	if (-e $dirname && -e "$fullDirPath/of.zip"){
		ex("rm -fr $fullDirPath");		
	}	
	
	if (-e $dirname) {
		print "Skipping $name because directory exists: $dirname\n";		
	}else {
		mkdir $dirname or die;
		chdir $dirname or die;
		my $cwd1=getcwd;
		print "Getting ", $name, " at url: $url\n";
		$of="of.zip";
		ex("curl $url --output $of --location");
		die "$of not there" unless -e $of;

		ex("$unzip $of");
		ex("rm $of");
			
		# my $ae = Archive::Extract->new( archive => $of );
		# 	    ### extract to cwd() ###
		# 	    my $ok = $ae->extract or die;
			
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
print VF "export PATH=$p:",'$',"PATH";
close VF;

$p=join(";",@bdirs);
print BF "set PATH=$p;","%PATH%";
close BF;

print "Done.\n";
