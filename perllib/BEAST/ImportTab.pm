#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

package ImportTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use htmlHelper;
use Data::Dumper;

use BEAST::ImportSets;
use BEAST::Set;

###
### Build the Browse Tab
###

sub new
{
	my $class = shift;
	my $self = {
		_input 		=> shift,
	};

	bless $self, $class;
	return $self;
}

sub printImportTab
{
	# hash ref to the input form data
	my $self = shift;
	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings
	my $input = $self->{'_input'};

	my $importtext = "";
	my @sets;
	if ($input->param('importtype') eq 'text') {
		if ($input->param('importtext')) {
			$importtext = $input->param('importtext');
			my @lines = split(/\n/, $importtext);
			@sets = ImportSets::parseSetLines(@lines);	
		}
	} else {
		#my $uploaded_filehandle = $input->upload('importtext');
	}

	print <<EOF;
	<form id="importform">
        <p class='radiO_selectors' id='textStyle'> 
	<input type='radio' name='importType' checked='checked' value='text' onclick='chooseTextImport(this.form)'>
	Enter sets to import
	</p>	
	<textarea name="importtext" id="setsImportFromText" cols="40" rows="5">$importtext</textarea><br>
	<p>
        <p class='radiO_selectors' id='fileStyle'> 
	<input type='radio' name='importType' value='file' onclick='chooseFileImport(this.form)'>
	Or import from a local file:
	</p>
	<input type='hidden' name='MAX_FILE_SIZE" value='200'>
	<input type='file' name="importtext" accept="text" id="setsImportFromFile" value="file" onclick="selectImportFile(this.form)">
	<input type='button' value='import' onClick="return onImportSets(this.form);"><br>
	</form>
	<p>Imported Sets:</p>
	<p>
EOF
	MySets::display_my_sets(@sets);
	print "</p>";
	

	## send back the sets here
	return @sets;	
}

1;
