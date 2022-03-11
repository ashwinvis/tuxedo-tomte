#!/usr/bin/perl
use warnings;
use strict;

use Gtk2::Notify -init, "app_name";

my $summary = 'Gtk2::Notify';

my $message = 'Hallo Welt!';

my $icon = '/usr/share/app-install/icons/podbrowser.png';

my $attach_widget = undef;

my $notification = Gtk2::Notify->new($summary, $message, $icon, $attach_widget);

$notification->show;

