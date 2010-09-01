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
use BEAST::SetsOverlap;
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
	my $type = shift;

	if (defined $session) {
		die unless (ref($session) eq 'CGI::Session');
	}

	# sanity check first: if no sets 
	return if (BeastSession::checkMySetsNull($session) == 0);
	# b64 encoded string
	my ($base64gif, $info, $rows);
	if ($type eq 'members') {
		($base64gif, $info, $rows) = getSetsMembersGif($session);
	} elsif ($type eq 'sets') {
		($base64gif, $info, $rows) = getSetsSetsGif($session);
	}

	if ($base64gif eq "" || $info eq "") {
		return;
	}
	
	printBase64GIF($base64gif, $info, $type, $rows);
}


sub printBase64GIF
{
	my $base64gifSTR = shift;
	my $infoSTR = shift;
	my $type = shift;
	my $rows = shift;

	# parse the JSON info
	my $json = JSON->new->utf8;
	my $jsonObj = $json->decode($infoSTR);

	my $width = $jsonObj->{'column_width'};
	my $columns = $jsonObj->{'columns'};
	my @columns = @$columns;

	my $height = $jsonObj->{'row_height'};
	#my $rows = $jsonObj->{'rows'};
	#my @rows = @$rows;

	my $infoStr_cols = $width."^";
	$infoStr_cols .= $columns[0];
	for my $i (1 .. $#columns) {
		$infoStr_cols .= ",".$columns[$i];
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

	filterNegativesAndThreshold($setsX);
	filterNegativesAndThreshold($setsY);

	if ($setsX eq "" || $setsY eq "") {
		return "";
	}

	#print Data::Dumper->Dump([$setsY->[0]]);
	my $filename = "/tmp/".$session->id;
	my $setsXfilename = $filename.".setsX";
	my $setsYfilename = $filename.".setsY";
	my @rows; # the gold stanard (X) file

	my $setXOrganism = $setsX->[0]->get_metadata_value('organism');
	my $setXSource = $setsX->[0]->get_source;
	my $setYOrganism = $setsY->[0]->get_metadata_value('organism');
	my $setYSource = $setsY->[0]->get_source;

	unless (open(SETSX, ">$setsXfilename"))  { 
		print "can't open tmp file!\n"; 
		return; 
	}
	foreach my $set (@$setsX)  {
		print SETSX $set->toString()."\n";
		push @rows, $set->get_name;
	}
	close (SETSX);

	unless (open(SETSY, ">$setsYfilename")) { 
		print "can't open tmp file!\n"; 
		return; 
	}
	# columns: the test set
	foreach my $set (@$setsY)  {
		print SETSY $set->toString()."\n";
	}
	close (SETSY);
	
	#print Data::Dumper->Dump([$setsY->[0]]);

	my $err_str;
	my $sets_overlap_prog = SetsOverlap->new(\$err_str, {
		'gold_file' => $setsXfilename,
		'test_file' => $setsYfilename,
		'gold_universe_file' => "/".$setXSource."/".$setXOrganism."/universe.lst",
		'test_universe_file' => "/".$setYSource."/".$setYOrganism."/universe.lst",
		'tmp_base_file' => $filename
	});

	unless (defined $sets_overlap_prog) {
		print $err_str."\n";
		return;
	}

	
	$sets_overlap_prog->run;
	my $test_sets_json = $sets_overlap_prog->parse_output_to_json;
#	$sets_overlap_prog->print_raw_output;
	$sets_overlap_prog->clean;

	my $json = getJSONMetadata($session);
	my $row_json = getJSONRowdata(@rows);
	$json = $json."\n".$row_json;
	$json .= "\n".$test_sets_json;

	#print $json;
	my ($gif, $info) = runJavaImageGen($session, $json);
	return ($gif, $info, \@rows);
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

	my $json = getJSONMetadata($session);


	foreach my $set (@sets) {
		$json = $json."\n"."[".$set->serialize()."]";
	}

	# build the list of entities -- the row column
	my @elements_array = MySets::sortElementsList(@sets);

	my $row_json = getJSONRowdata(@elements_array);
	$json = $json."\n".$row_json;

	my ($gif, $info) = runJavaImageGen($session, $json);
	return ($gif, $info, \@elements_array);
}

sub getJSONRowdata
{
	my @elements = @_;

	my $json = "[{\"_metadata\":{\"type\":\"rows\"},\"_elements\":{";
	$json .='"'.$elements[0].'":""';
	for my $i (1 .. (scalar(@elements) - 1)) {
		$json .= ',"'.$elements[$i].'":""';	
	}
	$json .= '}}]';

	return $json;
}

sub runJavaImageGen
{
	my $session = shift;
	my $json = shift;

	# tmp files
	my $filename = "/tmp/".$session->id.".txt";
	my $info_filename = $filename.".json";

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
			print "Error: couldn't create temp info file $info_filename";
			my $errlog = Constants::JAVA_ERROR_LOG;
			print `cat $errlog`;
		}

		return ($base64gif, $info);
	} else {
		print "Error: couldn't create temp file $filename";
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
