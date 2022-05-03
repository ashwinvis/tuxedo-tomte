#!/usr/bin/perl -w
use strict qw(vars subs);
use warnings;

my $LiveISO = 0;
my $consoleLanguage = 'LANG=C;LANGUAGE=C;';
my $sessionID = readFileReturnLine('/proc/sys/kernel/random/boot_id');
$sessionID =~ /(.{7})/;
$sessionID = hex($1);

sub readFileReturnLine {
	my $file = shift;
	my $FH;
	my $line;
	if ( open $FH, "<", $file ) {
		chomp($line = <$FH>);
		close $FH;
	} else {
		printLog("Err: $!", 'L0');
		printLog("no $file present or unable to open the file for reading", 'L0');
		return;
	}
	return $line;
}



# dialog-warning
# dialog-error
# dialog-information

sub message {
	my $summary = shift;
	my $body = shift;
	my $urgency = shift;
	my $icon = shift;
	my $mUsername = '';
	my $mPid = '';
	my $mLine = '';
	my @whoLines = `who -u`;

	# don't message the desktop if LiveISO
	if ($LiveISO) {
		return (0);
	}
	foreach $mLine (@whoLines) {
		if ($mLine =~ /\(:\d+\)/) {
			$mLine =~ /^(\w*).*\s(\d*)\s.*/;
			$mUsername = $1;
			$mPid = $2;
		}
	}
	if (($mUsername eq '') || ($mPid eq '')) {
		printLog('No display for message output found', 'L1');
		return (0);
	}
	my $dbusAddress;
	if ( open(FH, "<", "/proc/$mPid/environ") ) {
		$dbusAddress = do { local $/; <FH> };
		close FH;
	} else {
		printLog('No display for message output found', 'L1');
		return (0);
	}
	$dbusAddress =~ /.*?(DBUS_SESSION_BUS_ADDRESS=unix:path=\/run\/user\/\d*\/bus).*/;
	$dbusAddress = $1;
	if ($dbusAddress eq '') {
		printLog('No display for message output found', 'L1');
		return (0);
	}
	my $mCmd = $consoleLanguage."sudo -u $mUsername $dbusAddress gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify \"TUXEDO Tomte\" $sessionID \"$icon\" '$summary' '$body' '[]' '{\"urgency\": <$urgency>, \"desktop-entry\": <\"tuxedo-control-center\">}' 5000";
	`$mCmd`;
	if ($? != 0) {
		printLog('No display for message output found', 'L1');
		return (0);
	}
	return (1);
}

message("test", "this is my body, dialog-warning", 2, 'dialog-warning');
