#!/usr/bin/perl -w
use strict qw(vars subs);
use Fcntl qw(:DEFAULT :flock :seek :Fcompat);
use File::FcntlLock;
use Carp;
use warnings;
use autodie;
use 5.010;

use Data::Dumper qw(Dumper);

my $aptArchives = '/var/cache/apt/archives/lock';
my $aptListsLock = '/var/lib/apt/lists/lock';
my $libDpkgLock = '/var/lib/dpkg/lock';
my $lockFrontend = '/var/lib/dpkg/lock-frontend';

my $aptArchivesFH;
my $aptListsLockFH;
my $libDPKGLockFH;
my $lockFrontendFH;

my $allLocked = 1;

my $someNumber;

sub acquire_lock {
  my $fn = shift;
  my $justPrint = shift || 0;
  confess "Too many args" if defined shift;
  confess "Not enough args" if !defined $justPrint;

  my $rv = 1;
  my $fh;
  sysopen($fh, $fn, O_RDWR | O_CREAT) or die "failed to open: $fn: $!";
  $fh->autoflush(1);
  print "acquiring lock: $fn";
  my $fs = new File::FcntlLock;
  $fs->l_type( F_WRLCK );
  $fs->l_whence( SEEK_SET );
  $fs->l_start( 0 );
  $fs->lock( $fh, F_SETLKW ) or die  "failed to get write lock: $fn:" . $fs->error;
  my $num = <$fh> || 0;
  return ($fh, $num);
}

sub release_lock {
  my $fn = shift;
  my $fh = shift;
  my $num = shift;
  my $justPrint = shift || 0;

  seek($fh, 0, SEEK_SET) or die "seek failed: $fn: $!";
  print $fh "$num\n" or die "write failed: $fn: $!";
  truncate($fh, tell($fh)) or die "truncate failed: $fn: $!";
  my $fs = new File::FcntlLock;
  $fs->l_type(F_UNLCK);
  print "releasing lock: $fn";
  $fs->lock( $fh, F_SETLK ) or die "unlock failed: $fn: " . $fs->error;
  close($fh) or die "close failed: $fn: $!";
}

sub fileLock {
	my ($file) = @_;
	my $FH;	
	if (open ($FH, '+>', $file)) {
		if (flock($FH, LOCK_EX)) {
			print "got lock for $file\n";
		} else {
			print "cant get lock for $file $!\n";
			return undef;
		}
		print "lock successful for $file\n";
		print "press key: \n";
		<STDIN>;
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

#$aptArchivesFH = fileLock($aptArchives);
#$aptListsLockFH = fileLock($aptListsLock);
#$libDPKGLockFH = fileLock($libDpkgLock);
#$lockFrontendFH = fileLock($lockFrontend);

($lockFrontendFH, $someNumber) = acquire_lock($lockFrontend);


print "press key: \n";
<STDIN>;

release_lock($lockFrontend, $lockFrontendFH, 3, $someNumber);

#closeLock($aptArchivesFH);
#closeLock($aptListsLockFH);
#closeLock($libDPKGLockFH);
#closeLock($lockFrontendFH);


