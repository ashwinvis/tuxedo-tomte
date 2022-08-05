#!/usr/bin/perl -w
use strict qw(vars subs);
use warnings;
use autodie;
use 5.010;

use Data::Dumper qw(Dumper);

my $locksLog = 'locks.log';

while(1) {
	`lsof /var/cache/apt/archives/lock >> $locksLog`;
	`lsof /var/lib/apt/lists/lock >> $locksLog`;
	`lsof /var/lib/dpkg/lock >> $locksLog`;
	`lsof /var/lib/dpkg/lock-frontend >> $locksLog`;
	`echo '----------------------' >> $locksLog`;
	sleep(1);
}


