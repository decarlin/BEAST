#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use Data::Dumper;
use BEAST::Collection;
use BEAST::CheckBoxTree;
use BEAST::Constants;

package CollectionsTab;


sub new
{
	my $class = shift;
	my $self = {
		_input 		=> shift,
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

	# get active mysets objects
	my @mycollections = BeastSession::loadObjsFromSession($session, 'mycollections', Collection->new('constructor',""));	
	unless (ref($mycollections[0]) eq 'Collection') {
		pop @mycollections;
	}

	if (scalar(@mycollections) > 0) {
	# collection X

		my ($selectedX, $selectedY) = BeastSession::getSelectedCollectionNames($session);
		
		print <<MULTILINE_STR;
		<select name="collectionsX" id="collectionsX"> 
MULTILINE_STR
		foreach (@mycollections) {
			my $name = $_->get_name;
			my $selected = "";
			if ($name eq $selectedX) { $selected = "selected"; }
			print "<option value=\"$name\" $selected>$name</option>";
		}
		print "</select>";
		print "&nbsp;&nbsp; - Gold Collection (Rows)<br>";

	# collection Y
		print <<MULTILINE_STR;
		<select name="collectionsY" id="collectionsY"> 
MULTILINE_STR
		foreach (@mycollections) {
			my $name = $_->get_name;
			my $selected = "";
			if ($name eq $selectedY) { $selected = "selected"; }
			print "<option value=\"$name\" $selected>$name</option>";
		}
		print "</select>";
		print "&nbsp;&nbsp; - Test Collection (Columns)<br><div>&nbsp;</div>";
		print "<input type='button' id='update_selected_collections' value='Update Selected' onClick='return onUpdateSelectedCollections();'><br>";
		print "<div>&nbsp;</div>";

		if ($selectedX) {


		}

	}

	my @mysets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1,"", ""));	
	unless (ref($mysets[0]) eq 'Set') {
		pop @mysets;
	}
	return unless (scalar(@mysets) > 0); 
	
	print "<div><b>Add New Collection:</b></div>";
	print "<form id=\"new_collection\">";
	print "<input type='text' id='add_collection_name' value='Collection Name'>";
	print "<input type='button' id='add_collection' value='Add To Collections' onClick='return onAddCollection(this.form);'>";
	MySets::displaySetsTree("new_collection", "", @mysets);
	print "</form>";
			
}


1;
