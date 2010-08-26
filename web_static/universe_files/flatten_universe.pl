


while (<>) {
	chomp ($_);
	@parts = split (/\t/, $_);
	for my $i (1 .. (scalar(@parts) - 1)) {
		print $parts[$i]."\n";
	}
	

}
