#!/usr/bin/perl -w
use strict qw(vars subs);
use Fcntl qw(:flock);
use warnings;
use autodie;
use 5.010;

use Data::Dumper qw(Dumper);

my $aptArchives = '/var/cache/apt/archives/lock';
my $aptLists = '/var/lib/apt/lists/lock';
my $libDpkg = '/var/lib/dpkg/lock';
my $lockFrontend = '/var/lib/dpkg/lock-frontend';

my $aptArchivesFH;
my $aptListsFH;
my $libDPKGFH;
my $lockFrontendFH;

my $allLocked = 1;

sub fileLock {
	my ($file, $FH) = @_; 
	if (open $FH, '+<', $file) {
		if (flock($FH, LOCK_EX)) {
			print "got lock for $file\n";
		} else {
		   print "cant get lock for $file $!\n";
		   return (0);
		}
		print "lock successful for $file\n";
		return (1);
	} else {
		print "open for $file not possible\n";
		return (0);
	}
}

sub closeLock {
	my $FH;
	if(!close($FH)) {
		print "could not close filehandle\n";
	}
}

fileLock($aptArchives, $aptArchivesFH);
fileLock($aptLists, $aptListsFH);
fileLock($libDpkg, $libDPKGFH);
fileLock($lockFrontend, $lockFrontendFH);

sleep(3);

closeLock($aptArchivesFH);
closeLock($aptListsFH);
closeLock($libDPKGFH);
closeLock($lockFrontendFH);


