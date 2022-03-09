#!/usr/bin/perl
use Net::DBus;
my $bus = Net::DBus->system;
#my $bus = Net::DBus->session;
#my $svc = $bus->get_service('org.freedesktop.PowerManagement');
#my $obj = $svc->get_object('/org/freedesktop/PowerManagement', 'org.freedesktop.PowerManagement');
#my $id = $obj->Inhibit('appname', 'dialog-information');

my $svc = $bus->get_service('org.freedesktop.login1');
print "before obj\n";
my $obj = $svc->get_object('org/freedesktop/login1', 'org.freedesktop.login1.Manager');
print "before id\n";
my $id = $obj->Inhibit('shutdown', 'tuxedo-tomte', 'installing fixes', 'block');


print "enter: ";
my $input = <STDIN>;
