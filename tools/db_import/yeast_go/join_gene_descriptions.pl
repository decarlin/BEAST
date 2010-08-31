
open (SGD, "./SGD_features.tab") || die;
my @sgd = <SGD>;
close (SGD);

while (my $gene = <>) {
	chomp $gene;

	my $str;
	my $found = 0;
	my @matches = grep (/.*\t$gene\t.*/, @sgd);
	my @parts = split (/\t/, $matches[0]);	
	foreach my $part (@parts) {
		if ($part =~ /.*\s\S+.*;.*/) {
			chomp $part;
			$str =  $gene."\t".$part."\t".$gene."\t"."entrez^yeast\n";
			$found = 1;
			last;
		}
	}

	if ($found == 0) {
		$str = $gene."\t".$gene."\t".$gene."\t"."entrez^yeast\n";
	}

	$str =~ s/'/\\'/g; 
	$str =~ s/;/\\;/g; 

	print $str;	

}
