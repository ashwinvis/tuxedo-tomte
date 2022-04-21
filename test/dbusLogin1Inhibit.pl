#!/usr/bin/perl
use Net::DBus;
use IO::Handle;
use Scalar::Util qw(openhandle);
my $bus = Net::DBus->system;

print "before get_service\n";
my $svc = $bus->get_service('org.freedesktop.login1');
print "before obj\n";
my $obj = $svc->get_object('/org/freedesktop/login1', 'org.freedesktop.login1.Manager');
print "before id\n";

my $id = new IO::Handle;
my $id = IO::Handle->new();
$id = $obj->Inhibit('shutdown:sleep', 'tuxedo-tomte', 'installing fixes', 'block');

open($id);

if ($id->opened()) {
	print "open\n";
}

print "ID: $id\n";
print "reboot blocked, press enter to unblock";
my $input = <STDIN>;
