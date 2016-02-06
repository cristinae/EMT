#!/usr/bin/perl -w

#################################################################
# Description 
# Agafa la sortida nbestlist de moses i busca la frase amb
# millor BLEU i TER
#################################################################

use strict;
use Metrics;
use Matxin::Common;

# Check program arguments, and other initializations
my $argc = @ARGV;
if ($argc != 1) { die("\n Us: $0 <nbest file>\n\n");}

my $dosRefs = 0;
#my $refFile = '/home/cristinae/pln/devSoft/emt/data/SMatxinT0/ADMINtest.eu.tok';
#my $refFile = '/home/cristinae/pln/devSoft/emt/data/SMatxinT0/NEWStest.eu1.tok.0';
my $refFile2 = '/home/cristinae/pln/devSoft/emt/data/SMatxinT0/NEWStest.eu1.tok.1';
my $refFile = '/home/cristinae/pln/projectes/empreses/CA/jesus/envia/H2/files/enes/individualData/test3.clean.es';


my $IN = "$ARGV[0]";
my $FileB = $IN;
#$FileB =~ s/\.nbest10000Dist\.SMatxinT\.eutrad/\.oracleDistBLEU/;
#$FileB =~ s/\.nbest\.mix/\.mix\.oracleBLEU/;
#$FileB =~ s/\.10Mbest\.eu/\.10Mbest\.oracleBLEU/;
$FileB =~ s/nbestTrad\./nbestTrad\.oracleBLEU\./;
my $FileBalign = $FileB.'.align'; 

open(IN,"< $IN") || die("\n No es pot obrir el fitxer $IN\n\n");
open(OUTbleu,"> $FileB") || die("\n No es pot crear el fitxer $FileB\n\n");
open(OUTbleuA,"> $FileBalign") || die("\n No es pot crear el fitxer $FileBalign\n\n");
#open(OUTter,"> $FileT") || die("\n No es pot crear el fitxer $FileT\n\n");
open(REF,"< $refFile") || die("\n No es pot obrir el fitxer $refFile\n\n");
if ($dosRefs) {open(REF2,"< $refFile2") || die("\n No es pot obrir el fitxer $refFile2\n\n");}

my $bleu_ant=0; 
my $bleu=0; 
my $bestB='';
my $bestBfull='';
my $ter_ant=99999999; 
my $ter=99999999; 
my $bestT='';

my $target = <REF>;
chomp($target);
my $target2;
if ($dosRefs) {
   $target2 = <REF2>;
   chomp($target2);
}

my $frase_ant = 0;
my $i=0;
while (my $l = <IN>){
      chomp($l);
      my @trans = split(/ \|\|\| /, $l);
      my $fraseclean = $trans[1];
      if ($i==0) {$bestB=$trans[1];$bestBfull=$l;}
      $fraseclean =~ s/\'/\\\'/g;
      $fraseclean =~ s/\[SMT\]|\[CD\]|\[RBMT\]|\[BOTH\]|\[smt\]|\[cd\]|\[rbmt\]|\[both\]//g; 
      $fraseclean =~ s/\s+/ /g;
      $trans[0] =~ s/\s//g;

      my $suma =$frase_ant+1;
      if ($trans[0] == $suma) {
#         print "$trans[0]:$fraseclean\n->$bleu_ant, $bleu, $bestB\n\n";
 	 print OUTbleu "$bestB\n";
 	 print OUTbleuA "$bestBfull\n";
         $target = <REF>;
         chomp($target);
	 if ($dosRefs) {
	   $target2 = <REF2>;
	   chomp($target2);
	 }
         $frase_ant = $trans[0];
	 $bleu_ant=0; 
	 $bleu=0; 	
	 $bestB=$trans[1];
	 $bestBfull=$l;
	 $ter_ant=99999999; 
	 $ter=99999999; 
	 $bestT=$trans[1];
         Matxin::Common::show_progress($frase_ant, $Matxin::Common::progress0, $Matxin::Common::progress1);
      }

if ($frase_ant>-1){
      if ($fraseclean eq ' '){$fraseclean='.';} #xapussa
      #print "$frase_ant: $fraseclean i $target.";
      $bleu_ant = Metrics::calculaSbleu($fraseclean,$target);
      if ($dosRefs) {
         my $bleu_ant2 = Metrics::calculaSbleu($fraseclean,$target2);
         if ($bleu_ant2 > $bleu_ant) {$bleu_ant=$bleu_ant2;}             
      }

      if ($bleu_ant > $bleu) {
         $bleu=$bleu_ant;
         $bestB=$trans[1];
         $bestBfull=$l;
      }
}

#if ($frase_ant==279){
#      $ter_ant = Metrics::calculaTercom($fraseclean,$target,$frase_ant);
#      if ($dosRefs) {
#         my $ter_ant2 = Metrics::calculaTercom($fraseclean,$target2,$frase_ant);
#         if ($ter_ant2 < $ter_ant) {$ter_ant=$ter_ant2;}             
#      }
#      if ($ter_ant < $ter) {
#   	 $ter=$ter_ant;
#	 $bestT=$trans[1];
#      }
#}
    $i++;
}

 print OUTbleu "$bestB\n";
 print OUTbleuA "$bestBfull\n";
#print OUTter "$bestT\n";


close(IN);
close(OUTbleu);
close(OUTbleuA);
#close(OUTter);
close(REF);

