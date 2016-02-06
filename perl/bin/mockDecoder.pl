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
use Matxin::Systems;
use Metrics;

sub usage
{
   $0 =~ /\/([^\/]*$)/;
   print STDERR "\nUsage: ", $0, "  [options]  <xml_file>\n\n";
   print STDERR "Options:\n\n";
   print STDERR "  - max_rbmt <n>          : maximum number of alternative RBMT node translations ($Matxin::Common::max_alternatives_node_DEFAULT by default)\n";   
   print STDERR "  - max_smt <n>           : maximum number of alternative SMT chunk translations ($Matxin::Common::max_alternatives_node_DEFAULT by default)\n";   
   print STDERR "  - v                     : verbosity\n";
   print STDERR "  - help                  : this help\n";
   print STDERR "\nExample: $0 -v -max_rbmt 1 -max_smt 10 hybrid2.xml\n\n";
   exit;
}

# -- read options ------------------------------------------------------------------------------------
my %options = ();
GetOptions(\%options, "max_rbmt=i", "max_smt=i",
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

if ($verbose) { print STDERR "[mock decoder]\n"; }

#################################################################
#paths
my $ngramexe = 'ngram';
my $lm = '../../exp/hybrid/lmodels/lm_euskara.srilm';

#params
my $nbests = 1;
my $oracleMetric = 'sBleu';    #Ara son exclusius, o fa un o l'altre
#my $oracleMetric = 'ter';

#files
my $ref='../../data/hybrid_curt.eu.tok';
my $file='optionsBLEU.txt';
#################################################################
#main

if (-e "$file.probs"){system("rm $file.probs");}
if (-e "oracle.$oracleMetric.4TER"){system("rm oracle.$oracleMetric.4TER");}
if (-e "oracle.$oracleMetric.4BLEU"){system("rm oracle.$oracleMetric.4BLEU");}

if ($verbose) { print STDERR "reading $xml...\n"; }

my $twig = XML::Twig->new( keep_encoding => 1 );
if (-e $xml) { $twig->parsefile($xml); }
else { die "[ERROR] could not find XML file <$xml>\n"; }

if ($verbose) { print STDERR "processing segments..."; }

my $CORPUS = $twig->root;

#my @SEGMENTS = sort { $a->att('ord') <=> $b->att('ord') } $CORPUS->children;
my @SEGMENTS = sort { Matxin::Common::get_attribute_value($a, 'ord') <=> Matxin::Common::get_attribute_value($a, 'ord') } $CORPUS->children;
open(REF, "< $ref") or die("No s'ha pogut obrir $ref. Error: $!");

my $numSegment=0;

my $rbFileB = $xml;
$rbFileB =~ s/\.xml/\.RBMT/;
my $rbFileT = $rbFileB.'.4TER';
$rbFileB = $rbFileB.'.4BLEU';

my $smtFileB = $xml;
$smtFileB =~ s/\.xml/\.SMT/;
my $smtFileT =$smtFileB.'.4TER';
$smtFileB =$smtFileB.'.4BLEU';

my $RBoutB = new IO::File("> $rbFileB");
my $SMToutB = new IO::File("> $smtFileB");
my $RBoutT = new IO::File("> $rbFileT");
my $SMToutT = new IO::File("> $smtFileT");

foreach my $SEGMENT (@SEGMENTS) {
   my $matxin_segment = new Matxin::Segment($SEGMENT, $verbose);

   print STDERR "processing segment", $matxin_segment->ord(), "\n";

   &constructOptions($matxin_segment, $max_alternatives_node, $max_alternatives_trans, $verbose);  

   my $refSys = printRawSystems($SEGMENT, $matxin_segment, $verbose);
   print $RBoutB "@$refSys[0]\n"; 
   print $SMToutB "@$refSys[1]\n"; 
   print $RBoutT "@$refSys[0] ($numSegment)\n"; 
   print $SMToutT "@$refSys[1] ($numSegment)\n"; 
 
#    &scoreOptions($numSegment);

#   my $reference = <REF>;
#   &oracleOption($oracleMetric, $reference, $numSegment); 

   $numSegment++;
   if ($verbose) { Matxin::Common::show_progress($numSegment, $Matxin::Common::progress0, $Matxin::Common::progress1); }
}

if ($verbose) { print STDERR " $numSegment segments [DONE]"; }

$SMToutB->close();
$SMToutT->close();
$RBoutB->close();
$RBoutT->close();

close(REF);






#################################################################
#subs

sub constructOptions{
#entrada: sentence tree object 
#sortida: Arxiu $file amb totes les opcions

    my $matxin_segment = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $verbose = shift;

    my $hpaths = new Matxin::HybridPaths($matxin_segment, $max_alternatives_Node, $max_alternatives_AltTrans, $verbose);

    #print Dumper $hpaths;
    $hpaths->print_file($file);
}



sub printRawSystems{
#entrada: sentence tree object 
#sortida: 

    my $SEGMENT = shift;
    my $matxin_segment = shift;
    my $verbose = shift;

    my $systemsTrans = new Matxin::Systems($SEGMENT, $matxin_segment, $verbose);

#    print "@$systemsTrans[0]\n";
#    print "@$systemsTrans[1]\n";

     return ($systemsTrans);
}



sub scoreOptions{
#entrada: arxiu de text amb totes les Options per aplicar n-gram
#sortida: arxiu de text amb n-best list de cada frase


    my $sentence = shift;
    
#Word penalty contribution
    open(OPTIONS,"< $file") || die("\n No es pot obrir el fitxer $file\n\n");
    my @wp;
    my $i=0;
    while(<OPTIONS>){
	my @words = split(/ /, $_);
	$wp[$i] = -@words;
	$i++;
    }
    close(OPTIONS);


#Language model contribution
    system("$ngramexe -lm $lm -ppl $file.clean -debug 1 -order 5 > $file.plm ");
    open(IN,"< $file.plm") || die("\n No es pot obrir el fitxer $file.plm\n\n");
    my @lm;
    my $j=0;
    while(<IN>){
       my $frase = $_;
       chomp($frase);

# aixo es el final 
       if ($frase =~ /^file/) {last;}
       if ($frase =~ /\d+ zeroprobs, logprob= .+ ppl1= (-?\d+(\.\d+)?(e(\+|-)\d+)?)/ ) {
	  $frase =~ /\d+ zeroprobs, logprob= (-?\d+(\.\d+)?) ppl=/;
#	  $frase =~ /\d+ zeroprobs, logprob= .+ ppl1= (-?\d+(\.\d+)?)/;
	  $lm[$j] = $1;
	  $j++;
      }
   }
    close(IN);


#Sum of the models
   if ($j==$i){
      my @scores_sorted;
      open(PROBS,">> $file.probs") || die("\n No es pot crear el fitxer $file.probs\n\n");
      open(PROBSB,">> 1best.trad") || die("\n No es pot crear el fitxer 1best.trad\n\n");
#      open(PROBST,">> $file.1best.4TER") || die("\n No es pot crear el fitxer $file.1best.4TER\n\n");
      open(OPTIONS,"< $file") || die("\n No es pot obrir el fitxer $file\n\n");
      my $k=0;
      my @scores;
       while(<OPTIONS>){
	chomp;
	my $frase=$_;
	my $prob=$lm[$k]+$wp[$k];
	$scores[$k][1]="$frase ||| $lm[$k] $wp[$k] ||| ";
	$scores[$k][2]="$prob";
	$k++;
      }  
      close(OPTIONS);

      @scores_sorted = sort {$b->[2] <=> $a->[2]} @scores;
      my $end = ($nbests<$k) ? $nbests : $k;
      for(my $k=0; $k<$end;$k++) {
	  print PROBS "$scores_sorted[$k][1] $scores_sorted[$k][2] \n";
	  my $frase = $scores_sorted[$k][1];
          $frase =~ s/ \|\|\| .*//g;
	  print PROBSB "$frase\n";
# 	  print PROBST "$frase ($sentence)\n";
      }
      close(PROBS);
      close(PROBSB);
#      close(PROBST);


   }else{
      die("\nERROR: Different number of language model probability and word penalties.\n\n");
   }

    system("rm $file.plm");
    return;
}



sub oracleOption{
#entrada: arxiu de text amb totes les Options per aplicar n-gram
#sortida: arxiu de text amb n-best list de cada frase segons la metrica

    my $metrica = $_[0];
    my $target = $_[1];
    my $numSentence = $_[2];

    chomp($target);
    open(ORACLE_B,">> oracle.$oracleMetric.trad") || die("\n No es pot crear el fitxer oracle.$oracleMetric.trad\n\n");
#    open(ORACLE_T,">> oracle.$oracleMetric.4TER") || die("\n No es pot crear el fitxer oracle.$oracleMetric.4TER\n\n");
    open(OPTIONS,"< $file") || die("\n No es pot obrir el fitxer $file\n\n");

    if ($metrica eq 'sBleu'){
	my $bleu_ant=0; 
	my $bleu=0; 
	my $best='';
	while(<OPTIONS>){
	    chomp;
	    my $frase=$_;
	    my $fraseclean=$frase;
            $fraseclean =~ s/\[SMT\]|\[RBMT\]//g; 
            $bleu_ant = Metrics::calculaSbleu($fraseclean,$target);
	    if ($bleu_ant > $bleu) {
		$bleu=$bleu_ant;
		$best=$frase;
	    }
	}
	print ORACLE_B "$best\n";
#	print ORACLE_T "$best ($numSentence)\n";

     }elsif ($metrica eq 'ter'){
	my $ter_ant=99999999; 
	my $ter=99999999; 
	my $best='';
	while(<OPTIONS>){
	    chomp;
	    my $frase=$_;
	    my $fraseclean=$frase;
            $fraseclean =~ s/\[SMT\]|\[RBMT\]//g; 
            $ter_ant = Metrics::calculaTercom($fraseclean,$target,$numSentence);
	    if ($ter_ant < $ter) {
		$ter=$ter_ant;
		$best=$frase;
	    }
	}
	print ORACLE_B "$best\n";
#	print ORACLE_T "$best ($numSentence)\n";

     }else{
	  die("\nERROR: Metric not defined.\n\n");
     }
    
    close(OPTIONS);
    close(ORACLE_B);
 #   close(ORACLE_T);
    return;
}


