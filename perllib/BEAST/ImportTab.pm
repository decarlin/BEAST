#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

package ImportTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";

use htmlHelper;
use Data::Dumper;

use BEAST::Set;
use BEAST::BeastDB;

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

sub printTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift;
	my $fh = shift || undef;

	my @sets;

	die unless (ref($session) eq 'CGI::Session');

	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings
	my $input = $self->{'_input'};

	my $importtext = "";
	if ($input->param('importtype') eq 'text') 
	{
		if ($input->param('importtext')) 
		{
			$importtext = $input->param('importtext');
			my @lines = split(/\n/, $importtext);
			my $errstr;
			@sets = Set::parseSetLines(\$errstr, @lines);	
			if ($sets[0] == 0) {
				pop @sets;
				print "Failed to parse set lines!\n";
				print $errstr;
				return;
			}
		}
	} 

	if (defined $fh) {
		my @lines;
		while (my $line = <$fh>) {
		  push @lines, $line;	
		}
		my $errstr;
		@sets = Set::parseSetLines(\$errstr,  @lines);
		if ($sets[0] == 0) {
			pop @sets;
			print "Failed to parse set lines!\n";
			print $errstr;
			return;
		}
	}

	#print Data::Dumper->Dump([@sets]);

	&print_button_js;
	print <<MULTI_LINE_STR;
	<form id="importform">
		<p class='radiO_selectors' id='textStyle'> 
			<input type='radio' name='importType' checked='checked' value='text' onclick='chooseTextImport(this.form)'/> Enter sets to import<br/>
MULTI_LINE_STR


	print <<MULTI_LINE_STR;
		</p>
		<textarea name="importtext" id="setsImportFromText" cols="40" rows="5">$importtext</textarea><br/>
			<p class='radiO_selectors' id='fileStyle'> 
				<input type='radio' name='importType' value='file' onclick='chooseFileImport(this.form)'>
				Or import from a local file:
			</p>
MULTI_LINE_STR

	print <<MULTI_LINE_STR;
			<input type='hidden' name='MAX_FILE_SIZE" value='200'/>
			<input type='button'  id="file_upload_button" class="button" value='Upload File'/>
			<input type='button' value='Upload' onClick="return onImportSets(this.form);"/><br/>
	<p>Sets:</p>
	<p>
MULTI_LINE_STR
	if (scalar(@sets) > 0 && ref($sets[0]) eq 'Set') {

		# get the set of valid keyspace, and source options	
		my $beastDB = BeastDB->new;
		$beastDB->connectDB();

		my $sources_hash = {};
		my @sources = $beastDB->getKeyspaceSources();
		foreach my $source (@sources) {
			$sources_hash->{$source} = [ $beastDB->getOrganismsForKeyspaceSource($source) ];
		}
		$beastDB->disconnectDB();
		print Data::Dumper->Dump([$sources_hash]);		
		
			
		MySets::displaySetsTree("import", "", @sets);
		print <<MULTILINE_STR;
			<input type='button' value='Add To My Sets' onClick="return onAddImportSets(this.form);"/><br>
MULTILINE_STR
		# to do : merge with mysets
	
		BeastSession::saveObjsToSession($session, 'importsets', @sets);
	}
	print "</p></form>";


	## send back the sets here
	return @sets;
}

sub print_button_js
{
print <<MULTI_LINE_STR;
<script type= "text/javascript">
\$(document).ready(function(){

	var button = \$('#file_upload_button');
	new AjaxUpload(button,{
		action: '/cgi-bin/BEAST/index.pl',
		name: 'my_upload_file',
		onSubmit : function(file, ext)
		{
			// change button text, when user selects file			
			button.text('Uploading');
			
			// If you want to allow uploading only 1 file at time,
			// you can disable upload button
			this.disable();

			// Uploding -> Uploading. -> Uploading...
			interval = window.setInterval(function(){
				var text = button.text();
				if (text.length < 13)
				{
					button.text(text + '.');
				}
				else
				{
					button.text('Uploading');
				}
			}, 200);
		},
		onComplete: function(file, response)
		{
			button.text('Upload Complete');
			
			\$("#import").html(response);

			window.clearInterval(interval);
			
			// enable upload button
			this.enable();
			
			// add file to the list
			\$('<li></li>').appendTo('#example1 .files').text(file);
			
		}
	});
});
</script>
MULTI_LINE_STR
}


1;
