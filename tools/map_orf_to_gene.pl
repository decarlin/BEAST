
use Getopt::Long;


sub usage
{
	print <<EOF;

Usage: $0 --mappings=orf_to_genes.tab < orf_to_map.lst > converted_genes.txt
EOF

}

my $mappings = '';
GetOptions("mappings=s" => \$mappings);

die &usage() unless (-f $mappings);

open (ORF_TO_GENE, $mappings) || die "orf to genes!";
my $orf_to_gene_map = {};
while (my $line = <ORF_TO_GENE>) {
	chomp ($line);
	my ($orf, $gene) = split (/\t/, $line);
	$orf_to_gene_map->{$orf} = $gene;
}
close (ORF_TO_GENE);

while (<>) {
	chomp ($_);
	if (exists $orf_to_gene_map->{$_}) {
		print $orf_to_gene_map->{$_}."\n";
	} else {
		print $_."\n";
	}
}
