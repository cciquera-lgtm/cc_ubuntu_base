#!/usr/bin/perl -I/usr/local/ncpa/plugins/lib

################################################################################
#
# Name: check_open_files.pl --process <string> [--warn <number>] [--critical <number>] [--debug] [--help]
#
# What: Determines whether the number of open files handles from processes matching <string> are okay.
#
# Arguments:
#       --process  match ps output from <string>
#                  Alternative: -p
#                  Default: none
#       --warn     number of open file handles at which to provide warning alert
#                  critical threshold overrides
#                  Alternative: -w
#                  Default: 900
#       --critical number of open file handles at which to provide critical alert
#                  Alternative: -c
#                  Default: 1000
#       --debug    enable debug logging
#                  Alternative: -d
#                  Default: none
#       --help     print help message, then stop
#                  Alternative: -h
#                  Default: none
#
# Change History
# 2011/04/05
#       Initial version.
# 2013/04/16
#       Resolved performance issue with DNS resolution, where external IPs in list.
#       Improved error handling.
################################################################################

#####
# Packages.
#####
use strict;
use warnings;

use Getopt::Long;
use File::Basename;
use utils qw(%ERRORS);

#####
# Commands to use outside standard PATH.
#####
our $lsof;
$lsof = "/usr/bin/lsof";

#####
# Set default values.
#####
my $process = "";
my $warning_threshold = 900;
my $critical_threshold = 1000;
my $debug = 0;
my $help = 0;

#####
# Parse usage.
#####
GetOptions (
		"process=s" => \$process,
		"warning_threshold=i" => \$warning_threshold,
		"critical_threshold=i" => \$critical_threshold,
		"help" => \$help,
		"debug" => \$debug,
	) or Usage ( $ERRORS{'UNKNOWN'} );

#####
# Process help.
#####
Usage ( $ERRORS{'UNKNOWN'} ) if $help;

#####
# Validate options not validated by GetOptions.
#####
if (length($process) == 0) {
	print STDERR "Invalid usage: process string (--process) required\n";
	Usage ( $ERRORS{'UNKNOWN'} );
}

#####
# Get the list of processes matching the string.
#####
my @pids = `ps -efww | fgrep -i "$process" | fgrep -v $0 | fgrep -v fgrep`;

#####
# Determine the number of open file handles for each PID.
#####
my $openfile = 0;
foreach my $pid (@pids) {
	my ($user , $thispid , $rest) = split(/\s+/ , $pid);
	my @thisopencnt = `$lsof -n -p $thispid 2>> /usr/local/ncpa/plugins/tmp/openfiles.warn`;
	Debug ("pid $thispid has openfile count $#thisopencnt");
	$openfile = $#thisopencnt + $openfile;
}
Debug ("all matching pids have openfile count $openfile");

#####
# Determine the state: default to ok, warning overrides default, critical overrides warning.
#####
my $statusmsg = "OK: open files ($openfile) for $process is below threshold ($warning_threshold/$critical_threshold)";
my $statusstate = $ERRORS{'OK'};

if ( $openfile >= $warning_threshold ) {
	$statusmsg = "WARNING: open files ($openfile) for $process exceeds (threshold=$warning_threshold/$critical_threshold)";
	$statusstate = $ERRORS{'WARNING'};
}

if ( $openfile >= $critical_threshold ) {
	$statusmsg = "CRITICAL: open files ($openfile) for $process exceeds (threshold=$warning_threshold/$critical_threshold)";
	$statusstate = $ERRORS{'CRITICAL'};
}

#####
# Report results.
#####
print "$statusmsg|open_files=$openfile;$warning_threshold;$critical_threshold\n";
exit $statusstate;


################################################################################
# Name: Usage exitcode
# What: Handles usage errors, including displaying usage for --help.
################################################################################
sub Usage {
	my ($exitcode) = @_;

	my $progname = basename($0);
	print "$progname --process <string> [--warn <number>] [--critical <number>] [--debug] [--help]\n";

	exit $exitcode;
}

################################################################################
# Name: Debug message
# What: Prints <message> if --debug set.
################################################################################
sub Debug {
	print STDERR "DEBUG: @_\n" if $debug;
}

