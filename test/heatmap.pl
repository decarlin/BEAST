#!/usr/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Constants;

my $command = Constants::JAVA_BIN." -jar ".Constants::HEATMAP_JAR." < mitochondria.json";
print $command;
system($command);
