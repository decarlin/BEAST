#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.27.2010

package SetsOverlap;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";

our $TRUE = 1;
our $FALSE = 0;

use BEAST::Constants;

# Wrapper for sets_overlap.pl
sub new
{
	my $class = shift;
	my $self = shift;

#	my $self = {
#		'gold_file' 
#		'test_file'
#		'gold_universe_file' 
#		'test_universe_file'
#		'tmp_base_file' 
#	};	

	$self->{'perl_lib_dir'} = Constants::PERL_LIB_DIR;
	$self->{'perl_bin'} = Constants::PERL_32_BIN;
	$self->{'sets_overlap'} = Constants::SETS_OVERLAP;
	$self->{'universe_file_topdir'} = Constants::WEB_STATIC_DIR."/universe_files";
	

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

sub parse_output_to_json
{
	my $self = shift;

	my @test_sets;
	my $state = 'begin';

	my $current_test_set;	
	my $highest_score = 0;

	foreach my $line (@{$self->{'output'}}) {

		# in any state
		if ($line =~ /^>(\S+)$/) {
			my $test_set_name = $1;

			# end of last set
			if ($state eq 'gold_sets') {
				my $ref = $current_test_set;
				push @test_sets, $ref;
			}
	
			$current_test_set = Set->new($test_set_name, 1, { 'type' => 'hypergeometric'}, {}) ; 	
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
	# normalize all the set scores
	foreach my $set (@test_sets) {
		foreach my $name ($set->get_element_names) {
			my $score = $set->get_element($name);
			$set->set_element($name, $score / $highest_score);
		}
		$json_str .= $set->serialize()."\n";	
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
