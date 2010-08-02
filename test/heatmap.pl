#!/usr/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Constants;

my $json = <<EOF;
[{"_metadata":{"type":"info","action":"base64gif","filename":"heatmap.txt"}}]
[{"_metadata":{"name":"kinesin-associated mitochondrial adaptor activity","id":"154128","type":"set"},"_name":"human:GO:0019895","_delim":"^","_active":1,"_elements":{"TRAK1":""}}]
[{"_metadata":{"name":"mitochondrial proton-transporting ATP synthase complex, catalytic core F(1)","id":"142716","type":"set"},"_name":"human:GO:0000275","_delim":"^","_active":1,"_elements":{"ATP5E":"","ATP5C1":"","ATP5B":"","ATP5D":""}}]
EOF

my $command = Constants::JAVA_64_BIN." -jar ".Constants::HEATMAP_JAR." 1 >> /tmp/beast_heatmap_errfile.txt 2>&1";
open COMMAND, "|-", "$command";
print COMMAND $json;
close COMMAND;
