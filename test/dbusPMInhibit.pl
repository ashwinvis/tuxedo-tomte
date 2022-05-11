#!/usr/bin/perl
use Net::DBus;
use IO::Handle;
use Scalar::Util qw(openhandle);
my $bus = Net::DBus->session;
my $svc = $bus->get_service('org.freedesktop.PowerManagement');
my $obj = $svc->get_object('/org/freedesktop/PowerManagement', 'org.freedesktop.PowerManagement.Inhibit');
print "hasinhibit: $obj->HasInhibit()\n";


my $id = new IO::Handle;
$id = IO::Handle->new();
$id = $obj->Inhibit('tuxedo-tomte', 'making updates');
print "hasinhibit: $obj->HasInhibit()\n";

#print "before get_service\n";
#my $svc = $bus->get_service('org.freedesktop.login1');
#print "before obj\n";
#my $obj = $svc->get_object('/org/freedesktop/login1', 'org.freedesktop.login1.Manager');
#print "before id\n";

#foreach (@{$obj->ListUsers}) {
#	print "$_\n";
#}

#foreach my $dev (@{$obj->GetAllDevices}) {
#	print $dev, "\n";
#}

#$id = $obj->Inhibit('shutdown:sleep', 'tuxedo-tomte', 'installing fixes', 'block');

#$obj->Reboot(1);

open($id);

if ($id->opened()) {
	print "open\n";
}

print "ID: $id\n";
print "system reboot blocked, press enter to release";
my $input = <STDIN>;