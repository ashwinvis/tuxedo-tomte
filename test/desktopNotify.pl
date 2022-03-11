#!/usr/bin/perl

use Desktop::Notify;
 
# Open a connection to the notification daemon
my $notify = Desktop::Notify->new();
 
# Create a notification to display
my $notification = $notify->create(summary => 'Desktop::Notify',
                                   body => 'Hello, world!',
                                   timeout => 5000);
 
# Display the notification
$notification->show();
 
# Close the notification later
$notification->close();
