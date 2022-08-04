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
	my ($file) = @_;
	my $FH;	
	if (open ($FH, '+<', $file)) {
		if (flock($FH, LOCK_EX)) {
			print "got lock for $file\n";
		} else {
			print "cant get lock for $file $!\n";
			return undef;
		}
		print "lock successful for $file\n";
		return ($FH);
	} else {
		print "open for $file not possible\n";
		return undef;
	}
}

sub closeLock {
	my $FH = shift;
	if (defined $FH) {
		if(close($FH)) {
			print "closed filehandle\n";
		} else {
			print "unable to close filehandle\n";
		}
	} else {
		print "filehandle is not defined\n";
	}
}

$aptArchivesFH = fileLock($aptArchives);
$aptListsFH = fileLock($aptLists);
$libDPKGFH = fileLock($libDpkg);
$lockFrontendFH = fileLock($lockFrontend);

print "press key: \n";
<STDIN>;

closeLock($aptArchivesFH);
closeLock($aptListsFH);
closeLock($libDPKGFH);
closeLock($lockFrontendFH);


