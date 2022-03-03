#!/usr/bin/perl
use Net::DBus;
my $bus = Net::DBus->session;
my $svc = $bus->get_service('org.freedesktop.PowerManagement');
my $obj = $svc->get_object('/org/freedesktop/PowerManagement', 'org.freedesktop.PowerManagement');
my $id = $obj->Inhibit('appname', 'dialog-information');

print "enter: ";
my $input = <STDIN>;
