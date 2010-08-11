#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --sgadata=raw_file 
##
EOF
}

sub convert_from_sci
{
	my $sci_val = shift;

	my $float = Math::BigFloat->new($sci_val);

	return $float;
}

use Getopt::Long;
use Math::BigFloat;

my $sga_file = '';
GetOptions("sgadata=s" => \$sga_file);

die &usage() unless (-f $sga_file);

our $sga_interactions = {};

open (SGA, $sga_file) || die;
while (my $line = <SGA>) {
	chomp($line);	

	next if ($line =~ /^#/);	
	my (	$queryORF, 
		$queryGENE, 
		$arrayORF, 
		$arrayGENE,
		$interactionSCORE,
		$standardDEV,
		$pVAL
	) = split(/\t/, $line);

	#my $float_pVAL = convert_from_sci($pVAL);

	#print $queryGENE."\t".$queryGENE."\t".$arrayGENE."\t".$arrayGENE."\t".$interactionSCORE."\t".$standardDEV."\t".$float_pVAL."\n";	

	$queryGENE = uc($queryGENE);
	$arrayGENE = uc($arrayGENE);
	# map query_gene_name to 
	unless ($sga_interactions->{$queryGENE}) {
		$sga_interactions->{$queryGENE} = { $queryGENE => $interactionSCORE };
	} else {
		$sga_interactions->{$queryGENE}->{$queryGENE} = $interactionSCORE;
	}

	# now map the other
	unless ($sga_interactions->{$arrayGENE}) {
		$sga_interactions->{$arrayGENE} = { $queryGENE => $interactionSCORE };
	} else {
		$sga_interactions->{$arrayGENE}->{$queryGENE} = $interactionSCORE;
	}
}
close (SGA);

my $highestPOSITIVE = 0;
my $lowestNEGATIVE = 0;

foreach (keys %$sga_interactions) {
	my $gene = $_;
	foreach (keys %{$sga_interactions->{$gene}} ) {
		if ($sga_interactions->{$gene}->{$_} > $highestPOSITIVE) {
			$highestPOSITIVE = $sga_interactions->{$gene}->{$_};
		}
		if ($sga_interactions->{$gene}->{$_} < $lowestNEGATIVE) {
			$lowestNEGATIVE = $sga_interactions->{$gene}->{$_};
		}
	}
}
#print "lowest:".$lowestNEGATIVE."\n";
#print "highest:".$highestPOSITIVE."\n";

foreach (keys %$sga_interactions) {
	my $gene = $_;
	foreach (keys %{$sga_interactions->{$gene}} ) {
		print "$gene\t".$_."\t";
		my $score = $sga_interactions->{$gene}->{$_};
		my $normalizedSCORE;
		if ($score > 0) {
			$normalizedSCORE = $score / $highestPOSITIVE;
		} else {
			$normalizedSCORE = $score / (-$lowestNEGATIVE);
		}
		print $normalizedSCORE."\n";
	}
}

