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
[{"_metadata":{"type":"info","action":"base64gif","filename":"/tmp/4aef68c0514d371032994c4653fb7f47.txt"}}]
[{"_metadata":{"id":"151513","name":"viral reproduction","type":"set"},"_name":"human:GO:0016032","_delim":"^","_active":1,"_elements":{"INSR":"","LIG4":"","EIF5A":"","PARD6A":"","ACE2":"","CD209":"","TARBP2":"","HTATSF1":"","WWP2":"","FURIN":"","HIPK2":"","TGFB1":"","NEDD4":"","OPRK1":"","DERL1":"","HCFC1":"","ERVK6":"","SMARCB1":"","HMGA1":"","CD4":"","ERVK5":"","GFI1":"","BANF1":"","ICAM1":"","CD81":"","PVRL1":"","CXCR4":"","UACA":"","CCR5":"","CALCOCO2":"","USF1":"","CXCR6":"","CCL2":"","CCL1":"","TSG101":"","PPIA":"","HCFC2":"","HS3ST6":"","CTBP1":"","UBP1":"","WWP1":"","HBXIP":"","CCL4":"","PCSK5":"","PSIP1":"","NFIA":"","VAPB":"","CLEC4M":"","SMAD3":"","XRCC5":"","PVRL2":"","XRCC4":"","CTBP2":"","RRAGA":"","ITCH":"","SUPT5H":"","XRCC6":""}}]
EOF

my $command = Constants::JAVA_BIN." -jar ".Constants::HEATMAP_JAR." 1 >> /tmp/beast_heatmap_errfile.txt 2>&1";
open COMMAND, "|-", "$command";
print COMMAND $json2;
close COMMAND;
