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

	# b64 encoded string
	my $base64gif = getBase64Gif($session);

	if ($base64gif eq "") {
		print "Error: can't display image";
	}

	my $embeddedImage = "<img src=\"data:image/gif;base64,".$base64gif."\"/>";
	print "<div>".$embeddedImage."</div>";
	print "!!".$base64gif."!!";
}

sub getBase64Gif
{
	my $session = shift;

	my @sets = BeastSession::loadLeafSetsFromSession($session, 'mysets');

	my $filename = "/tmp/".$session->id.".txt";
	my $json = "[{\"_metadata\":{\"type\":\"info\",\"action\":\"base64gif\",\"filename\":\"$filename\"}}]";
	foreach my $set (@sets) {
		$json = $json."\n"."[".$set->serialize()."]";
	}

	my $command = Constants::JAVA_BIN." -jar ".Constants::HEATMAP_JAR." ";
	open COMMAND, "|-", "$command" || die "Can't pipe to java binary!";
	print COMMAND $json;
	close COMMAND;

	print $json;
	my $base64gif = "";
	if (-f $filename) {
		open GIF, $filename || return "";
		while (<GIF>) {
			$base64gif .= $_;		
		}
		close GIF;
		unlink($filename);

		return $base64gif;
	} else {
		print "Error: couldn't create temp file";
	}

	return "";
}

1;
