#!/usr/bin/perl -w

#################################################################
# Description 
# 
#################################################################

use strict;
use XML::Twig;
use Getopt::Long;
use Data::Dumper;
use Matxin::Common;
use Matxin::Segment;
use Matxin::HybridPaths;
use Matxin::HybridTable;
use Matxin::Systems;
use Metrics;

our ($trace, $cd);  

sub usage
{
   $0 =~ /\/([^\/]*$)/;
   print STDERR "\nUsage: ", $0, "  [options]  <xml_file>\n\n";
   print STDERR "Options:\n\n";
   print STDERR "  - max_rbmt <n>          : maximum number of alternative RBMT node translations ($Matxin::Common::max_alternatives_node_DEFAULT by default)\n";   
   print STDERR "  - max_smt <n>           : maximum number of alternative SMT chunk translations ($Matxin::Common::max_alternatives_node_DEFAULT by default)\n";   
   print STDERR "  - c                     : include Context Discriminated SMT translations (0/1)\n";
   print STDERR "  - p                     : number of parts to divide the test set\n";
   print STDERR "  - o                     : output path\n";
   print STDERR "  - t                     : keep trace of the system in the TT (0/1)\n";
   print STDERR "  - v                     : verbosity\n";
   print STDERR "  - help                  : this help\n";
   print STDERR "\nExample: $0 -max_rbmt 1 -max_smt 1 -c 0 -p 1 -t 1 -o ./hybrid3/ -v ../../data/hybrid3.xml\n\n";
   exit;
}

# -- read options ------------------------------------------------------------------------------------
my %options = ();
GetOptions(\%options, "max_rbmt=i", "max_smt=i", "c=i", "p=i", "o=s", "t=i",
                      "v!", "help!");

if ($options{"help"}) { usage(); }

# -- check number of argments
my $NARG = 1;
my $ARGLEN = scalar(@ARGV);
if ($ARGLEN < $NARG) { die usage(); }
my $xml = shift(@ARGV);

my $verbose = $options{"v"};
my $max_alternatives_node = $Matxin::Common::max_alternatives_node_DEFAULT;
if (defined($options{"max_rbmt"})) { $max_alternatives_node = $options{"max_rbmt"}; }
my $max_alternatives_trans = $Matxin::Common::max_alternatives_trans_DEFAULT;
if (defined($options{"max_smt"})) { $max_alternatives_trans = $options{"max_smt"}; }
my $parts = $Matxin::Common::parts_DEFAULT;
if (defined($options{"p"})) { $parts = $options{"p"}; }
$main::trace = $Matxin::Common::trace_DEFAULT;
if (defined($options{"t"})) { $main::trace = $options{"t"}; }
$main::cd = $Matxin::Common::cd_DEFAULT;
if (defined($options{"c"})) { $main::cd = $options{"c"}; }



#################################################################
#files
my ($res,$nom) = split(/.*\//, $xml);
if ($nom =~ /(.+)\.xml/){ $nom = $1;}

my $path ='./'.$nom.'/';
if (defined($options{"o"})) { $path = $options{"o"}; }
system ("mkdir $path") unless (-d $path);

my $file = $path.'phrase-table.'.$nom;
my $test = $path.'test.'.$nom;
if (-e "$file"){system("rm $file");}
if (-e "$test"){system("rm $test");}

my $rbFile = $path.$nom.'.RBMT';
my $smtFileb = $path.$nom.'.SMTb';
my $smtFileg = $path.$nom.'.SMTg';

#################################################################
#debugging parameter
my $flag = 0;

#################################################################
#main

if ($verbose) { print STDERR "[mock phrase table]\n"; }
if ($verbose) { print STDERR "reading $xml...\n"; }

my $twig = XML::Twig->new( keep_encoding => 1 );
if (-e $xml) { $twig->parsefile($xml); }
else { die "[ERROR] could not find XML file <$xml>\n"; }

if ($verbose) { print STDERR "processing segments..."; }

my $CORPUS = $twig->root;
my @SEGMENTS = sort { Matxin::Common::get_attribute_value($a, 'ord') <=> Matxin::Common::get_attribute_value($a, 'ord') } $CORPUS->children;

my $lastSegmentObject = $SEGMENTS[$#SEGMENTS]; #per acabar mirant el numero de segments per poder particionar
my $lastmatxin_segment = new Matxin::Segment($lastSegmentObject, $verbose);
my $lastSegmentNumber = $lastmatxin_segment->ord();
my $interval = int($lastSegmentNumber/$parts);

my $RBout = new IO::File("> $rbFile");
my $SMToutb = new IO::File("> $smtFileb");
my $SMToutg = new IO::File("> $smtFileg");

my %word_counts;
my $part = 1;
my $numSegment=0;
foreach my $SEGMENT (@SEGMENTS) {
   my $matxin_segment = new Matxin::Segment($SEGMENT, $verbose);

#   print STDERR "processing segment ", $matxin_segment->ord(), "\n";

   if ($numSegment >= $interval*$part) {
       $part++;
       $file = $path.'phrase-table.'.$nom.'.'.$part;
       $test = $path.'test.'.$nom.'.'.$part;
       if (-e "$file"){system("rm $file");}
       if (-e "$test"){system("rm $test");}
   }

   &constructTable($matxin_segment, $max_alternatives_node, $max_alternatives_trans, \%word_counts, $verbose);  

   my $refSys = printRawSystems($SEGMENT, $matxin_segment, $verbose);
   print $RBout ''.Matxin::Common::replace_xml_entities(@$refSys[0])."\n"; 
   print $SMToutb ''.Matxin::Common::replace_xml_entities(@$refSys[1])."\n"; 
   print $SMToutg ''.Matxin::Common::replace_xml_entities(@$refSys[2])."\n"; 
#	print Dumper $refSys;
 
   $numSegment++;
   if ($verbose) { Matxin::Common::show_progress($numSegment, $Matxin::Common::progress0, $Matxin::Common::progress1); }
}

if ($verbose) { print STDERR "\n $numSegment segments [DONE]\n"; }

$RBout->close();
$SMToutb->close();
$SMToutg->close();
 
#################################################################
#subs

sub constructTable{
#entrada: sentence tree object 
#sortida: Arxiu $file amb totes les opcions

    my $matxin_segment = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $word_counts = shift;
    my $verbose = shift;

    my $htable = new Matxin::HybridTable($matxin_segment, $max_alternatives_Node, $max_alternatives_AltTrans, $word_counts, $verbose);

    $htable->print_file($file, $test);

}



sub printRawSystems{
#entrada: sentence tree object 
#sortida: 

    my $SEGMENT = shift;
    my $matxin_segment = shift;
    my $verbose = shift;

    my $systemsTrans = new Matxin::Systems($SEGMENT, $matxin_segment, $verbose);

    return ($systemsTrans);
}

