#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.27.2010

package SetsOverlap;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/projects/sysbio/beast/perllib";

our $TRUE = 1;
our $FALSE = 0;

use Math::BigFloat;
use BEAST::Constants;

# Wrapper for sets_overlap.pl
sub new
{
	my $class = shift;
	my $setsX = shift;
	my $setsY = shift;

	my $self = {};
	$self->{'gold_sets'} = $setsX;
	$self->{'test_sets'} = $setsY;

	$self->{'perl_lib_dir'} = Constants::PERL_LIB_DIR;
	$self->{'perl_bin'} = Constants::PERL_32_BIN;
	$self->{'sets_overlap'} = Constants::SETS_OVERLAP;
	$self->{'universe_file_topdir'} = Constants::WEB_STATIC_DIR."/universe_files";
	$self->{'normalization_constant'} = Constants::HEATMAP_NORM_CONSTANT;
	
	bless $self, $class;
	return $self;
}

sub get_cmd
{
	my $self = shift;

	my $cmd = $self->{'perl_bin'}." ";
	$cmd .= $self->{'sets_overlap'}." ";
	$cmd .= $self->{'gold_file'}." ";
	$cmd .= $self->{'test_file'}." ";
	$cmd .= " -UG ".$self->{'universe_file_topdir'}.$self->{'gold_universe_file'}." ";
	$cmd .= " -UT ".$self->{'universe_file_topdir'}.$self->{'test_universe_file'}." ";
	$cmd .= " > ".$self->get_tmp_output_file;

	return $cmd;
}

sub get_tmp_output_file
{
	my $self = shift;

	return $self->{'tmp_base_file'}.".sets_overlap.out";
}

sub run
{
	my $self = shift;
	my $session = shift;
	my $err_str = shift;

	my $setsX = $self->{'gold_sets'};
	my $setsY = $self->{'test_sets'};

	# first write out the files
	my $filename = "/tmp/".$session->id;
	my $setsXfilename = $filename.".setsX";
	my $setsYfilename = $filename.".setsY";
	my @rows; # the gold stanard (X) file

	my $setXOrganism = $setsX->[0]->get_metadata_value('organism');
	my $setXSource = $setsX->[0]->get_source;
	my $setYOrganism = $setsY->[0]->get_metadata_value('organism');
	my $setYSource = $setsY->[0]->get_source;

	unless (open(SETSX, ">$setsXfilename"))  { 
		$$err_str =  "can't open tmp file!\n"; 
		return 0;
	}
	foreach my $set (@$setsX)  {
		print SETSX $set->toString()."\n";
		push @rows, $set->get_name;
	}
	close (SETSX);

	unless (open(SETSY, ">$setsYfilename")) { 
		$$err_str = "can't open tmp file!\n"; 
		return 0;
	}

	# columns: the test set
	foreach my $set (@$setsY)  {
		print SETSY $set->toString()."\n";
	}
	close (SETSY);

	#print `cat $setsXfilename`;
	#print "<br><br>";
	#print `cat $setsYfilename`;

	# set internal 
	$self->{'gold_file'} = $setsXfilename;
	$self->{'test_file'} = $setsYfilename;
	$self->{'gold_universe_file'} = "/".$setXSource."/".$setXOrganism."/universe.lst";
	$self->{'test_universe_file'} = "/".$setYSource."/".$setYOrganism."/universe.lst";
	$self->{'tmp_base_file'} = $filename;

	unless (-f Constants::WEB_STATIC_DIR."/universe_files".$self->{'gold_universe_file'}) {
		$$err_str = "No Gold Universe File:".$self->{'gold_universe_file'}; 
		return 0;
	}
	unless (-f Constants::WEB_STATIC_DIR."/universe_files".$self->{'test_universe_file'}) {
		$$err_str = "No Test Universe File:".$self->{'test_universe_file'}; 
		return 0;
	}

	$ENV{'MYPERLDIR'} = $self->{'perl_lib_dir'};

	my $cmd = $self->get_cmd;
	my $output = `$cmd`;

	my $output_file = $self->get_tmp_output_file;

	open (OUTPUT, $output_file) || return 0;
	my @lines = <OUTPUT>;
	close (OUTPUT);
	unlink($output_file);

	$self->{'output'} = [ @lines ];

	return 1;		
}

sub get_json
{
	my $self = shift;

	my @test_sets;
	my $state = 'begin';

	my $current_test_set;	
	my $highest_score = 0;

	Math::BigFloat->accuracy(5);

	foreach my $line (@{$self->{'output'}}) {

		# in any state
		if ($line =~ /^>(\S+)$/) {
			my $test_set_name = $1;

			# end of last set
			if ($state eq 'gold_sets') {
				my $ref = $current_test_set;
				push @test_sets, $ref;
			}

			$current_test_set = Set->new($test_set_name, 1, { 'type' => 'set'}, {}) ; 	
			$state = 'gold_sets';
			next;
		}
	
		if ($state eq 'gold_sets') {
			my @comps = split(/,/,$line);
			#print $line."<br>";
			# normalize the log10 of the p value
			if (-$comps[1] > $highest_score) {
				$highest_score = -$comps[1];
			}

			$current_test_set->set_element($comps[0], -$comps[1]);
		}
	}
	push @test_sets, $current_test_set;


	#print Data::Dumper->Dump([@test_sets]);	

	my $json_str = "";

	my $norm_factor;
	if ($self->{'normalization_constant'} < $highest_score) {
		$norm_factor = $self->{'normalization_constant'};
	} else {
		$norm_factor = $highest_score;
	}
	
	# normalize all the set scores
	foreach my $set (@test_sets) {
		foreach my $name ($set->get_element_names) {
			my $score = $set->get_element($name);
			my $normalized_score = $score / $norm_factor;
			if ($score > $norm_factor) {
				$normalized_score = 1;
			} else {
				$normalized_score = $score / $norm_factor;
			}

			# JSON double's can't deal with high precision: chop of the mantissa
			my $float = Math::BigFloat->new($normalized_score);

			$set->set_element($name, $float->bstr());
		}
		$json_str .= "[".$set->serialize()."]\n";	
	}

	return $json_str;
}

sub print_raw_output
{
	my $self = shift;
	foreach (@{$self->{'output'}}) {
		print $_."<br>";
	}
}

sub clean
{
	my $self = shift;

	unlink($self->{'gold_file'});
	unlink($self->{'test_file'});
	unlink($self->get_tmp_output_file);
}

1;
