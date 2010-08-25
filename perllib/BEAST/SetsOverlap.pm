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
