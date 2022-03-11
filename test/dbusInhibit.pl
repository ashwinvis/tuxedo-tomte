#!/usr/bin/perl
use Net::DBus;
use IO::Handle;
use Scalar::Util qw(openhandle);
my $bus = Net::DBus->system;
#my $bus = Net::DBus->session;
#my $svc = $bus->get_service('org.freedesktop.PowerManagement');
#my $obj = $svc->get_object('/org/freedesktop/PowerManagement', 'org.freedesktop.PowerManagement');
#my $id = $obj->Inhibit('appname', 'dialog-information');

print "before get_service\n";
my $svc = $bus->get_service('org.freedesktop.login1');
print "before obj\n";
my $obj = $svc->get_object('/org/freedesktop/login1', 'org.freedesktop.login1.Manager');
print "before id\n";

#foreach (@{$obj->ListUsers}) {
#	print "$_\n";
#}

#foreach my $dev (@{$obj->GetAllDevices}) {
#	print $dev, "\n";
#}

#my $id = new IO::Handle;
my $id = IO::Handle->new();
$id = $obj->Inhibit('shutdown:sleep:idle:handle-power-key:handle-suspend-key:handle-hibernate-key:handle-lid-switch', 'tuxedo-tomte', 'installing fixes', 'block');

#$obj->Reboot(1);

if ($id->opened()) {
	print "open\n";
}

print "ID: $id\n";
print "enter: ";
my $input = <STDIN>;
