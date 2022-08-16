#!/usr/bin/perl -w
use strict qw(vars subs);
use Fcntl qw(:flock);
use warnings;
use autodie;
use 5.010;

use Data::Dumper qw(Dumper);

my $file = '/var/lib/dpkg/lock-frontend';
my $FH;

if (open ($FH, '+>', $file)) {
	if (flock($FH, LOCK_EX | LOCK_NB)) {
		print "got lock for $file\n";
	} else {
		print "cant get lock for $file $!\n";
		return undef;
	}
	print "lock successful for $file\n";
	print "press key: \n";
	<STDIN>;

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
