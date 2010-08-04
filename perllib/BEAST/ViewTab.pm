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
	print $embeddedImage;
}

sub getBase64Gif
{
	my $session = shift;

	my @sets = BeastSession::loadLeafSetsFromSession($session, 'mysets');

	my $filename = "/tmp/".$session->id.".txt";
	my $json = "[{\"_metadata\":{\"type\":\"info\",\"action\":\"base64gif\",\"filename\":\"$filename\"";
	$json .= ',"width":"'.Constants::VIEW_WIDTH.'","height":"'.Constants::VIEW_HEIGHT.'"';
	$json .= "}}]";
	foreach my $set (@sets) {
		$json = $json."\n"."[".$set->serialize()."]";
	}

	# debug
	#my $test_json = $json;
	#$test_json =~ s/\n/<br>/g;	
	#print $test_json;

	my $command = Constants::JAVA_32_BIN." -jar ".Constants::HEATMAP_JAR." 1 > ".Constants::JAVA_ERROR_LOG." 2>&1";
	open COMMAND, "|-", "$command" || die "Can't pipe to java binary!";
	print COMMAND $json;
	close COMMAND;

	# debug
	# print $command;

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
		my $errlog = Constants::JAVA_ERROR_LOG;
		print `cat $errlog`;
	}

	return "";
}

1;
