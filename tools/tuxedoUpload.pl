#!/usr/bin/perl -w
use strict qw(vars subs);
use warnings;

# for debugging
use Data::Dumper;
use File::Basename;

my $keyfile = '/home/pablo/.ssh/pablohome';
my @fileList;
my @fileListWithPath;
my $argument;
my $flavour = '';
my $repo = '';
my $retValue;
my $errorValue;
my %repos = (
	test => 'testdeb-tuxedo',
	live => 'deb-tuxedo');

if (! -e $keyfile) {
	print "keyfile $keyfile does not exist\n";
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
	exit (0);
}

foreach $argument (@ARGV) {
	if ($argument =~ /(^bionic$|^focal$|^jammy$)/) {
		$flavour = $argument;
	} elsif ($argument =~ /(^test$|^live$)/) {
		$repo = $argument;
	} elsif (($argument =~ /\.deb/) && (-e $argument)) {
		print "valid file: $argument found\n";
		push @fileListWithPath, $argument;
		push @fileList, basename($argument);
	} else {
		print "$argument is not a deb-file or valid command\n";
		exit (0);
	}
}

if ($flavour eq '') {
	print "no valid flavour given [bionic|focal|jammy]\n";
	exit (0);
}
if ($repo eq '') {
	print "no valid repo given [test|live]\n";
	exit (0);
}
print "Repo: $repos{$repo}\n";
print "Flavour: $flavour\n";
if (@fileListWithPath == 0) {
	print "no valid files to transmit given [.deb]\n";
	exit (0);
}

my $cmd = "scp -i $keyfile @fileListWithPath root\@px02.tuxedo.de:/mnt/repos/$repos{$repo}/ubuntu/incoming/";
print "command: $cmd\n";

#TODO debug
exit (0);

$retValue = `$cmd`;
$errorValue = ${^CHILD_ERROR_NATIVE};
if ($errorValue != 0) {
	print "some error has happened while uploading\n";
	print "error value: $errorValue\n";
	print "return value:\n$retValue";
	exit (0);
}


$cmd = "ssh -i $keyfile root\@px02.tuxedo.de \"cd /mnt/repos/$repos{$repo}/ubuntu/incoming/ && mv @fileList /root/fais-pablo/\"";
print "cmd: $cmd\n";
$retValue = `$cmd`;
$errorValue = ${^CHILD_ERROR_NATIVE};
if ($errorValue != 0) {
	print "some error has happened while executing remote command\n";
	print "error value: $errorValue\n";
	print "return value:\n$retValue";
	exit (0);
}
