#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

package ImportTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use htmlHelper;
use Data::Dumper;

use BEAST::Set;

###
### Build the Browse Tab
###

sub new
{
	my $class = shift;
	my $self = 
	{
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

	my $metadata = 
	{
		'db_origin' => [ 'kegg', 'wikipathways', 'reactone' ],
		'genespace' => [ 'entrez' ],
	};

	my $importtext = "";
	my @sets;
	if ($input->param('importtype') eq 'text') 
	{
		if ($input->param('importtext')) 
		{
			$importtext = $input->param('importtext');
			my @lines = split(/\n/, $importtext);
			@sets = Set::parseSetLines($metadata, @lines);	
		}
	}
	else 
	{
		#my $uploaded_filehandle = $input->upload('importtext');
	}

	print <<MULTI_LINE_STR;
	<form id="importform">
		<p class='radiO_selectors' id='textStyle'> 
			<input type='radio' name='importType' checked='checked' value='text' onclick='chooseTextImport(this.form)'/> Enter sets to import<br/>
MULTI_LINE_STR

	my $formMetadata = {};
	my @formMetadata = $input->param('metadata[]');
	foreach (@formMetadata)
	{
		my ($key, $value) = split(/:/, $_);
		$formMetadata->{$key} = $value;
	}

	foreach (keys %$metadata) 
	{
		my $type = $_;
		my $key = "metadata_".$type;
		print "<b>$type&nbsp&nbsp</b><select name='$key'>";
		foreach (@{$metadata->{$type}})
		{
			if ($formMetadata->{$key} eq $_)
			{
				print "<option value='$_' selected>$_</option>";
			}
			else
			{
				print "<option value='$_'>$_</option>";
			}
		}
		print "</select><br>";
	}

	print <<MULTI_LINE_STR;
		</p>
		<textarea name="importtext" id="setsImportFromText" cols="40" rows="5">$importtext</textarea><br/>
			<p class='radiO_selectors' id='fileStyle'> 
				<input type='radio' name='importType' value='file' onclick='chooseFileImport(this.form)'>
				Or import from a local file:
			</p>
			<input type='hidden' name='MAX_FILE_SIZE" value='200'/>
			<input type='file' name="importtext" accept="text" id="setsImportFromFile" value="file" onclick="selectImportFile(this.form)"/>
			<input type='button' value='Upload' onClick="return onImportSets(this.form);"/><br/>
	</form>
	<p>Sets:</p>
	<p>
MULTI_LINE_STR
	MySets::displaySets("import", @sets);
	print "</p>";
	

	## send back the sets here
	return @sets;
}

1;
