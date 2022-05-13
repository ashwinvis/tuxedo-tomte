#!/usr/bin/perl -w
# needs ubuntu package libnet-openssh-perl and libexpect-perl
# change $keyFile to your private key to access root@px02

use strict qw(vars subs);
use warnings;

# for debugging
use Data::Dumper;
use File::Basename;
use File::Path;
use File::Copy;
use Cwd qw(getcwd);
use Net::OpenSSH;
use Expect;
use Term::ReadKey;

# for expect
select STDOUT; $| = 1;
select STDERR; $| = 1;
#TODO debug
my $debug = 1;
my $timeout = 20;
my $repoPassword = 'test';
my $pty;
my $pid;

my $keyFile = '/home/pablo/.ssh/pablohome';
my @fileList;
my @fileListWithPath;
my $zipFiles = 0;
my $tmpDir = '/tmp/repoupload/';
my $argument;
my $flavour;
my @flavours;
my $repo = '';
my $retValue;
my $errorValue;
my $testing = 0;
my $keyFilePassword;
my %repos = (
	testdeb => 'testdeb-tuxedo',
	live => 'deb-tuxedo');

sub usage {
	print "usage:\n";
	print "tuxedoUpload.pl [test] [bionic|focal|jammy] [testdeb|live] [file1.deb|...] [file1.zip|...]\n";
	print "multiple flavours are possible";
}

# prompt for password without showing in the terminal
sub promptForPassword {
	# Tell the terminal not to show the typed chars
	Term::ReadKey::ReadMode('noecho');

	print "Type in the password for the repository: ";
	my $password = Term::ReadKey::ReadLine(0);

	# Rest the terminal to what it was previously doing
	Term::ReadKey::ReadMode('restore');

	# The one you typed didn't echo!
	print "\n";

	# get rid of that pesky line ending
	$password =~ s/\R\z//;

	# say "Password was <$password>";
	return $password;
}

if (! -e $keyFile) {
	print "keyfile $keyFile does not exist\n";
	print "please do the following to create a keyfile:\n";
	print "ssh-keygen -t rsa -b 4096 -f [somename]\n";
	print "copy the public key [somename.pub] on to the server\n";
	print "and copy the content into .ssh/authorized_keys\n";
	print "move the private key [somename] to .ssh/\n";
	print "add the filename of the private key in \$keyfile on top of this script\n";
	print "\n";
	exit (0);
}

if (@ARGV == 0) {
	print "no arguments given\n";
	usage();
	exit (0);
}

foreach $argument (@ARGV) {
	if ($argument =~ /(^test$)/) {
		$testing = 1;
		print "testmode activated, no changes will be applied to the repos\n";
	} elsif ($argument =~ /(^bionic$|^focal$|^jammy$)/) {
		push @flavours, $argument;
	} elsif ($argument =~ /(^testdeb$|^live$)/) {
		$repo = $argument;
	} elsif (($argument =~ /^.*\.deb$/) && (-e $argument)) {
		print "valid deb-file: $argument found\n";
		push @fileListWithPath, $argument;
		$argument = basename($argument);
		push @fileList, "incoming/$argument";
	} elsif (($argument =~ /^.*\.zip$/) && (-e $argument)) {
		print "valid zip-file: $argument found\n";
		if (! -e $tmpDir) {
			mkdir($tmpDir);
		} else {
			print "can't create $tmpDir to unzip files\n";
			exit (0);
		}
		`unzip -j $argument "*.deb" -d $tmpDir`;
		$zipFiles = 1;
	} else {
		print "$argument is not a deb-file/zip-file or valid command\n";
		usage();
		exit (0);
	}
}

if (@flavours == 0) {
	print "no valid flavour given [bionic|focal|jammy]\n";
	usage();
	exit (0);
}
if ($repo eq '') {
	print "no valid repo given [testdeb|live]\n";
	usage();
	exit (0);
}

if ($zipFiles) {
	opendir(DIR, $tmpDir);
	while (my $file = readdir(DIR)) {
		next if ($file =~ m/^\./);
		push (@fileListWithPath, $tmpDir.$file);
		push (@fileList, "incoming/$file");
	}
	closedir(DIR);
}

print "with path: @fileListWithPath\n";
print "list: @fileList\n";

print "Repo: $repos{$repo}\n";
print "Flavours: @flavours\n";
if (@fileListWithPath == 0) {
	print "no valid files to transmit given [.deb]\n";
	usage();
	exit (0);
}

my $ssh = Net::OpenSSH->new('px02.tuxedo.de',
							user=>'root',
							key_path=>$keyFile);
$ssh->error and die "SSH connection failed: " . $ssh->error;

# copy files to server
print "copy @fileListWithPath to /mnt/repos/$repos{$repo}/ubuntu/incoming/\n";

if (! $testing) {
	$ssh->scp_put(@fileListWithPath, "/mnt/repos/$repos{$repo}/ubuntu/incoming/");
	rmdir($tmpDir);
	$ssh->error and die "scp failed: ".$ssh->error;
	print "all files copied to remote\n";
}

$repoPassword = promptForPassword();

# execute reprepro
my $firstFlavour = 1;
my $expect;
foreach $flavour (@flavours) {
	#$cmd = "ssh -i $keyFile root\@px02.tuxedo.de \"cd /mnt/repos/$repos{$repo}/ubuntu/ && reprepro --ask-passphrase -V includedeb $flavour @fileList\"";
	
	if (! $testing) {
		print "cmd: cd /mnt/repos/$repos{$repo}/ubuntu/; reprepro --ask-passphrase -V includedeb $flavour @fileList\n";
		if ($firstFlavour) {
			$firstFlavour = 0;
			($pty, $pid) = $ssh->open2pty("cd /mnt/repos/$repos{$repo}/ubuntu/; reprepro --ask-passphrase -V includedeb $flavour @fileList")
				or die "open2pty failed: " . $ssh->error . "\n";
			$expect = Expect->init($pty);
			$expect->raw_pty(1);
			$debug and $expect->log_user(1);

			$debug and print "waiting for password prompt\n";
			if ($expect->expect($timeout, 'Passphrase:')) {
				$debug and  print "prompt seen\n";

				$expect->send("$repoPassword\n");
				$debug and print "repo password sent\n";
			} else {
				print "no password requested\n";
			}
		} else {
			$expect->send("cd /mnt/repos/$repos{$repo}/ubuntu/; reprepro --ask-passphrase -V includedeb $flavour @fileList")
				or die "next reprepro command failed: " . $ssh->error . "\n";
		}

		$expect->expect($timeout, 'InRelease.new')
    		or die "bad repo password\n";
		$debug and print "repo password ok\n";

		while(<$pty>) {
    		print "$. $_";
		}
		$expect->soft_close();
	}
}
