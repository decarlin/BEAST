


while (<>) {
	chomp $_;
	my @parts = split(/\t/, $_);
	my $line =  $parts[1]."^ex_id=".$parts[0];
	$line .= "^source=go";
	for my $i (2 .. $#parts) {
		$line .= "\t".$parts[$i];
	}
	print $line."\n";

}
