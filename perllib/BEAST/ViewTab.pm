#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	7.24.2010

package ViewTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use htmlHelper;
use Data::Dumper;
use BEAST::BeastSession;
use BEAST::Constants;

our $TRUE = 1;
our $FALSE = 0;

###
### Build the Search Tab
###

sub new
{
	my $class = shift;
	my $self = {
	};

	bless $self, $class;
	return $self;
}

sub printTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift || undef;

	if (defined $session) {
		die unless (ref($session) eq 'CGI::Session');
	}

	writeGIF($session);
}

sub writeGIF
{
	my $session = shift;

	my @sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}

	my $filename = "/tmp".$session->id.".gif";
	my $json = "[{\"_metadata\":{\"type\":\"info\",\"action\":\"gif\",\"filename\":\"$filename\"}}]";
	foreach my $set (@sets) {
		$json = $json."\n"."[".$set->serialize()."]";
	}
	my $command = Constants::JAVA_BIN." -jar ".Constants::HEATMAP_JAR." ";
	open COMMAND, "|-", "$command" || die "Can't pipe to java binary!";
	print COMMAND $json;
	close COMMAND;
}

1;
