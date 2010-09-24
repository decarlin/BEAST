#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	7.24.2010

package ViewTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";
use POSIX;
use IO::Socket;

use htmlHelper;
use Data::Dumper;
use BEAST::BeastSession;
use BEAST::Constants;
use BEAST::SetsOverlap;
use BEAST::MySets;
use JSON -convert_blessed_universally;

use lib Constants::PERL_LIB_DIR;

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
	my $type = shift;

	if (defined $session) {
		die unless (ref($session) eq 'CGI::Session');
	}

	# sanity check first: if no sets 
	return if (BeastSession::checkMySetsNull($session) == 0);
	# b64 encoded string
	my ($base64gif, $rows, $columns);
	if ($type eq 'members') {
		($base64gif, $rows, $columns) = getSetsMembersGif($session);
	} elsif ($type eq 'sets') {
		($base64gif, $rows, $columns) = getSetsSetsGif($session);
	}

	if ($base64gif eq "") {
		return;
	}
	
	printBase64GIF($base64gif, $type, $rows, $columns);
}


sub printBase64GIF
{
	my $base64gifSTR = shift;
	my $type = shift;
	my $rows = shift;
	my $columns = shift;

	my $num_rows = scalar(@$rows);
	my $num_columns = scalar(@$columns);

	# compute the width 
	my $width = Constants::VIEW_WIDTH / $num_columns;
	my $height = Constants::VIEW_HEIGHT / $num_rows;

	my $infoStr_cols = $width."^";
	$infoStr_cols .= $columns->[0];
	for my $i (1 .. scalar(@$columns) - 1) {
		$infoStr_cols .= ",".$columns->[$i];
	}

	my $infoStr_rows = $height."^";
	$infoStr_rows .= $rows->[0];
	for my $i (1 .. (scalar(@$rows) - 1)){
		$infoStr_rows .= ",".$rows->[$i];
	}

	print "<input id=\"$type\_gif_info_columns\" type=\"hidden\" value='$infoStr_cols'/>";
	print "<input id=\"$type\_gif_info_rows\" type=\"hidden\" value='$infoStr_rows'/>";
	print "<img id=\"$type\_grid_image_div\" onClick='onImageClick(event, \"$type\")' onMouseMove='onImageHover(event, \"$type\")' src=\"data:image/gif;base64,".$base64gifSTR."\"/>";
}

# depricated: faster to do this in the SQL statement
sub filterNegativesAndThreshold
{
	my $ref = shift;

	my $threshold = Constants::SET_MEMBER_THRESHOLD;
	foreach my $set (@$ref) {
		foreach my $name ($set->get_element_names) {
			my $element = $set->get_element($name);	
			if ($element =~ /.*\d+.*/) {

				if ($element < $threshold) {
					$set->delete_element($name);	
				}
			} 
		}
	}
}

sub getSetsSetsGif
{
	my $session = shift;

	# return array references, or empty strings if not loaded
	my ($setsX, $setsY) = BeastSession::loadSetsForActiveCollections($session);

	# hopefully only the test set will be local (don't need this for the DB sets)
	#filterNegativesAndThreshold($setsY);
	if ($setsX eq "" || $setsY eq "") {
		return "";
	}


	## Any class that implements this virtual interface
	# must implement run, get_json, and clean methods. 
	my $err_str;

	my $collectionComparator = BeastSession::getCollectionComparator($session, $setsX, $setsY);
	if ($collectionComparator->run($session, \$err_str) == 0) {
		print $err_str;
		return;
	}
	my $test_sets_json = $collectionComparator->get_json;
	#$collectionComparator->print_raw_output;
	$collectionComparator->clean;

	my @rows;
	foreach my $set (@$setsX) {
		push @rows, $set->get_name;
	}

	my @columns;
	foreach my $set (@$setsY) {
		push @columns, $set->get_name;
	}


	my $json = getJSONMetadata($session);
	my $row_json = getJSONRowdata(@rows);
	$json = $json."\n".$row_json;
	$json .= "\n".$test_sets_json;

	#print $json;
	my $gif = runJavaImageGen($session, $json);
	return ($gif, \@rows, \@columns);
}

sub getJSONMetadata
{
	my $session = shift;

	my $filename = "/tmp/".$session->id.".txt";

	my $json = "[{\"_metadata\":{\"type\":\"info\",\"action\":\"base64gif\",\"filename\":\"$filename\"";
	$json .= ',"width":"'.Constants::VIEW_WIDTH.'","height":"'.Constants::VIEW_HEIGHT.'"';
	$json .= "}}]";

	return $json;
}

sub getSetsMembersGif
{
	my $session = shift;
	
	my @sets = BeastSession::loadLeafSetsFromSession($session, 'mysets', 0, 1);

	# reorder by clustering
	my ($X, $Y) = BeastSession::getSelectedCollectionNames($session);
	unless (  (!$X || $X eq "") || (!$Y || $Y eq "")) {
		my ($collectionX, $collectionY) = BeastSession::getSelectedCollections($session, $X, $Y);
		unless (!$collectionX || $collectionX eq "") {
			@sets = $collectionX->order_sets(@sets);
		}
		unless (!$collectionY || $collectionY eq "") {
			@sets = $collectionY->order_sets(@sets);
		}
	}

	my $json = getJSONMetadata($session);

	my @json_sets;
	foreach my $set (@sets) {
		# we have to remove the Entity objects and replace with a membership value
		# to properly serialize set objects
		my $new_set = $set->to_json_heatmap_str;
		$json = $json."\n"."[".$new_set->serialize()."]";
		push @json_sets, $new_set;
	}


	# build the list of entities -- the row column
	my @elements_array = MySets::sortElementsList(@json_sets);

	my @columns;
	foreach my $set (@sets) {
		push @columns, $set->get_name;
	}

	my $row_json = getJSONRowdata(@elements_array);
	$json = $json."\n".$row_json;

	my $gif = runJavaImageGen($session, $json);
	return ($gif, \@elements_array, \@columns);
}

sub getJSONRowdata
{
	my @elements = @_;

	# use eval to remove any quotations, etc
	my $json = "[{\"_metadata\":{\"type\":\"rows\"},\"_elements\":[";

	my $tmp = $elements[0];
	if ($tmp =~ /^\".*\"$/) {
		$tmp = eval($tmp);
	}

	$json .='"'.$tmp.'"';
	for my $i (1 .. (scalar(@elements) - 1)) {
		my $tmp = $elements[$i];
		if ($tmp =~ /^\".*\"$/) {
			$tmp = eval($tmp);
		}
		$json .= ',"'.$tmp.'"';	
	}
	$json .= ']}]';

	return $json;
}

sub runJavaImageGen
{
	my $session = shift;
	my $json = shift;

	# tmp files
	my $sock = new IO::Socket::INET( 
        	PeerAddr => "localhost",
        	PeerPort => 7777, 
        	Proto => 'tcp');

	my $stat = $!;
	unless ($sock) {
		print "Couldn't connect to heatmap daemon: $stat";
		return;	
	}

	print $sock $json."\n";
	print $sock "EOF\n"; 

	my $gifB64Str = "";
	while (my $line = <$sock>) {
		$gifB64Str .= $line;
	}
	return $gifB64Str;
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
