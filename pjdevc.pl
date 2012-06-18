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
gradle|GRADLE_HOME|Http://gradle.artifactoryonline.com/gradle/distributions/gradle-1.0-milestone-5-all.zip|1.0-m5|1
groovy|GROOVY_HOME|http://dist.groovy.codehaus.org/distributions/groovy-binary-1.8.3.zip|1.8.3|1
grails|GRAILS_HOME|http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.0.zip|2.0.0|1
griffon|GRIFFON_HOME|http://dist.codehaus.org/griffon/griffon/0.9.x/griffon-0.9.5-bin.zip|0.9.5|1
ivy|IVY_HOME|http://mirror.cc.columbia.edu/pub/software/apache/ant/ivy/2.2.0/apache-ivy-2.2.0-bin.zip|2.2.0|1
ant|ANT_HOME|http://apache.mirrors.tds.net//ant/binaries/apache-ant-1.8.4-bin.zip|1.8.4|1
maven|MAVEN_HOME|http://www.eng.lsu.edu/mirrors/apache//maven/binaries/apache-maven-3.0.4-bin.zip|3.0.4|1
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
	my ($name, $evname, $url, $version,$dearchive) = split (/\|/, $line);
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

		if ($dearchive) {
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
}
$p=join(":",@pdirs);
print VF "export PATH=$p:",'$',"PATH\n";
print VF "export GRAILS_OPTS='-Xmx1G -Xms256m -XX:MaxPermSize=256m'\n";

close VF;

$p=join(";",@bdirs);
print BF "set PATH=$p;","%PATH%\n";
print BF "set GRAILS_OPTS='-Xmx1G -Xms256m -XX:MaxPermSize=256m'\n";
close BF;

print "Done.\n";
