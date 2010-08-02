#!/usr/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Constants;

my $json = <<EOF;
[{"_metadata":{"type":"info","action":"base64gif","filename":"heatmap.txt"}}]
[{"_metadata":{"name":"kinesin-associated mitochondrial adaptor activity","id":"154128","type":"set"},"_name":"human:GO:0019895","_delim":"^","_active":1,"_elements":{"TRAK1":""}}]
[{"_metadata":{"name":"mitochondrial outer membrane","id":"146187","type":"set"},"_name":"human:GO:0005741","_delim":"^","_active":1,"_elements":{"GK2":"","MUL1":"","ACSL6":"","TOMM70A":"","CHPT1":"","BCL2L11":"","CPT1C":"","RHOT2":"","NOS1":"","BAX":"","WASF1":"","ACSL3":"","CPT1B":"","BID":"","MSTO1":"","KIF2A":"","MCL1":"","BCL2":"","CISD1":"","HOOK1":"","MARCH5":"","MOSC2":"","VDAC3":"","VDAC1":"","TOMM20":"","CYB5A":"","GIMAP5":"","ACSL5":"","AKAP1":"","MYLIP":"","TOMM5":"","TMEM173":"","ACSL4":"","SH3GLB1":"","TOMM34":"","MED12":"","AIFM2":"","MGST1":"","RAF1":"","KMO":"","VDAC2":"","MFF":"","FIS1":"","CYB5B":"","MTX2":"","MFN1":"","CYB5R3":"","BAK1":"","NLRX1":"","SAMM50":"","GPAM":"","MFN2":"","RAB11FIP5":"","BAD":"","MTX1":"","TOMM40":"","BBC3":"","BCL2L1":"","TOMM40L":"","TOMM22":"","GK":"","SPATA19":"","PI4KB":"","MAOA":"","PRDX2":"","TOMM7":"","TSPO":"","VAMP1":"","GK3P":"","SYNJ2BP":"","MAOB":"","RHOT1":""}}]
[{"_metadata":{"name":"mitochondrial outer membrane","id":"117686","type":"set"},"_name":"mouse:GO:0005741","_delim":"^","_active":1,"_elements":{"Gimap3":"","Tomm40":"","Vdac3":"","Tomm7":"","Ppp1cc":"","Bax":"","Mfn2":"","Vdac2":"","Mcsp":"","Pdcd8":"","Mfn1":"","Tomm20":"","Cpt1b":"","Gk2":"","Synj2bp":"","Wasf1":"","Vdac1":""}}]
[{"_metadata":{"name":"mitochondrial proton-transporting ATP synthase complex, catalytic core F(1)","id":"142716","type":"set"},"_name":"human:GO:0000275","_delim":"^","_active":1,"_elements":{"ATP5E":"","ATP5C1":"","ATP5B":"","ATP5D":""}}]
EOF

my $json2 = <<EOF;
[{"_metadata":{"type":"info","action":"base64gif","filename":"/tmp/5624b2a436b71b65d0ea74438b6ef745.txt"}}]
[{"_metadata":{"name":"viral reproduction","type":"set","id":"123012"},"_name":"mouse:GO:0016032","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"viral reproduction","type":"set","id":"151513"},"_name":"human:GO:0016032","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"negative regulation of viral reproduction","type":"set","id":"165498"},"_name":"human:GO:0048525","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"negative regulation of viral reproduction","type":"set","id":"165498"},"_name":"human:GO:0048525","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"regulation of viral reproduction","type":"set","id":"166682"},"_name":"human:GO:0050792","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"positive regulation of viral reproduction","type":"set","id":"165497"},"_name":"human:GO:0048524","_delim":"^","_active":1,"_elements":{}}]
[{"_metadata":{"name":"positive regulation of viral reproduction","type":"set","id":"165497"},"_name":"human:GO:0048524","_delim":"^","_active":1,"_elements":{}}]
EOF

my $command = Constants::JAVA_64_BIN." -jar ".Constants::HEATMAP_JAR." 1 >> /tmp/beast_heatmap_errfile.txt 2>&1";
open COMMAND, "|-", "$command";
print COMMAND $json2;
close COMMAND;
