#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	7.24.2010

package ViewTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use POSIX;
use htmlHelper;
use Data::Dumper;
use BEAST::BeastSession;
use BEAST::Constants;
use BEAST::MySets;
use JSON -convert_blessed_universally;

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

	# sanity check first: if no sets 
	return if (BeastSession::checkMySetsNull($session) == 0);
	# b64 encoded string
	my ($base64gif, $info) = getBase64Gif($session);

	if ($base64gif eq "") {
		print "Error: can't display image";
	}

	my $json = JSON->new->utf8;
	my $jsonObj = $json->decode($info);

	my $width = $jsonObj->{'column_width'};
	my $columns = $jsonObj->{'columns'};
	my @columns = @$columns;

	my $height = $jsonObj->{'row_height'};
	my $rows = $jsonObj->{'rows'};
	my @rows = @$rows;

	my $infoStr_cols = $width."^";
	$infoStr_cols .= $columns[0];
	for my $i (1 .. $#columns) {
		$infoStr_cols .= ",".$columns[$i];
	}

	my $infoStr_rows = $height."^";
	$infoStr_rows .= $rows[0];
	for my $i (1 .. $#rows) {
		$infoStr_rows .= ",".$rows[$i];
	}

	my $infotag_col = "<input id=\"gif_info_columns\" type=\"hidden\" value='$infoStr_cols'/>";
	my $infotag_row = "<input id=\"gif_info_rows\" type=\"hidden\" value='$infoStr_rows'/>";
	my $embeddedImage = "<img id=\"grid_image_div\" onClick='onImageClick(event)' onMouseMove='onImageHover(event)' src=\"data:image/gif;base64,".$base64gif."\"/>";
	print $infotag_col;
	print $infotag_row;
	print $embeddedImage;
}

sub getBase64Gif
{
	my $session = shift;
	
	my @sets = BeastSession::loadLeafSetsFromSession($session, 'mysets', 0, 1);

	my $filename = "/tmp/".$session->id.".txt";
	my $info_filename = $filename.".json";
	my $json = "[{\"_metadata\":{\"type\":\"info\",\"action\":\"base64gif\",\"filename\":\"$filename\"";
	$json .= ',"width":"'.Constants::VIEW_WIDTH.'","height":"'.Constants::VIEW_HEIGHT.'"';
	$json .= "}}]";
	foreach my $set (@sets) {
		$json = $json."\n"."[".$set->serialize()."]";
	}

	# build the list of entities -- the row column
	my @elements_array = MySets::sortElementsList(@sets);

	$json .= "\n[{\"_metadata\":{\"type\":\"rows\"},\"_elements\":{";
	$json .='"'.$elements_array[0].'":""';
	for my $i (1 .. (scalar(@elements_array) - 1)) {
		$json .= ',"'.$elements_array[$i].'":""';	
	}
	$json .= '}}]';

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

		my $info;
		if (-f $info_filename) {
			open INFO, $info_filename || return "";
			my @lines = <INFO>;
			$info = $lines[0];
			$info =~ s/^\s+//;	
			close INFO;
			unlink($info_filename);
			BeastSession::saveGifInfoToSession($session, $info);
		} else {
			print "Error: couldn't create temp info file";
			my $errlog = Constants::JAVA_ERROR_LOG;
			print `cat $errlog`;
		}

		return ($base64gif, $info);
	} else {
		print "Error: couldn't create temp file";
		my $errlog = Constants::JAVA_ERROR_LOG;
		print `cat $errlog`;
	}

	return "";
}

sub getColumn($$$)
{
	my $jsonObj = shift;
	my $x_coord = shift;
	my $y_coord = shift;

	my $col = $jsonObj->{'column_width'};
	my @sets = @{$jsonObj->{'columns'}};

	my $index = $x_coord / $col;
	$index = floor($index);
	return $sets[$index];
}


1;
