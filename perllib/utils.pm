#!/usr/bin/perl -w
#Author:            Sam Boyarsky (xenicson@gmail.com)
#Create Date:       11/05/2007
#Last Edit Date:    03/04/2008
#Location:          ~/samb/bin/utils.pm

package utils;

use strict; 
use warnings;
use English;
use Pod::Usage;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(trim log_base TRUE FALSE currentTime min max setFilePermissions getTimestamp);
our @EXPORT_OK  = qw();
our $VERSION    = 1.20;
use constant DEBUG => 0;
use constant FALSE => 0;
use constant TRUE => 1;

sub getTimestamp()
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	if ($mon < 10) { $mon = "0$mon"; }
	if ($hour < 10) { $hour = "0$hour"; }
	if ($min < 10) { $min = "0$min"; }
	if ($sec < 10) { $sec = "0$sec"; }
	$year=$year+1900;

	return $year . $mon . $mday . $hour . $min . $sec;
}


sub setFilePermissions($$)
{
    my($filename, $permissions) = @_;
    system("chmod $permissions $filename");
}

#This Trim function was inspired by code found at the following two websites:
#http://www.somacon.com/p114.php        (11/20/2007)
#http://perldoc.perl.org/perlop.html    (11/20/2007)
sub trim
{
    my $str = shift;
    for ($str)
    {	# trim whitespace
	    s/^\s+//;
	    s/\s+$//;
    }
    return $str;
}

#This log_base function was merged from code found in the O'Reilly book Programming Perl 
#and code from the following website: 
#http://www.unix.org.ua/orelly/perl/cookbook/ch02_14.htm     (11/20/2007)
sub log_base($$)
{
    my ($logBase, $value) = @_;
    return log($value)/log($logBase);
}

#this function comes from:
#http://perl.about.com/od/perltutorials/a/perllocaltime_2.htm (02/19/2008)
sub currentTime()
{
    my(@months) = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my(@weekDays) = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    my($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    my($year) = 1900 + $yearOffset;
    my($theTime) = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    return $theTime;
}

sub max($$)
{
    my($lhs, $rhs) = @_;
    return $lhs > $rhs ? $lhs : $rhs;
}

sub min($$)
{
    my($lhs, $rhs) = @_;
    return $lhs < $rhs ? $lhs : $rhs;
}


return 1;

__END__

=pod

=head1 utils module

=head1 SYNOPSIS

trim

log_base

min

max


=head1 DESCRIPTION


=cut
