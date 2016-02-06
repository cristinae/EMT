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

my $refFile = '/home/cristina/pln/devSoft/emt/data/SMatxinT/ADMINtest.eu.tok';
my $IN = "$ARGV[0]";
my $FileT = $IN;
$FileT =~ s/\.nbest\.trad/\.oracleTER3/;

open(IN,"< $IN") || die("\n No es pot obrir el fitxer $IN\n\n");
#open(OUTbleu,"> $FileB") || die("\n No es pot crear el fitxer $FileB\n\n");
open(OUTter,"> $FileT") || die("\n No es pot crear el fitxer $FileT\n\n");
open(REF,"< $refFile") || die("\n No es pot obrir el fitxer $refFile\n\n");


my $bleu_ant=0; 
my $bleu=0; 
my $bestB='';
my $ter_ant=99999999; 
my $ter=99999999; 
my $bestT=$bestB;

my $target = <REF>;
chomp($target);
my $frase_ant = 0;
my $i=0;
while (my $l = <IN>){
      chomp($l);
      my @trans = split(/ \|\|\| /, $l);
      my $fraseclean = $trans[1];
      if ($i==0) {$bestB=$trans[1];}
      #print "$fraseclean\n";
      $fraseclean =~ s/\'/\\\'/g;
      $fraseclean =~ s/\[SMT\]|\[RBMT\]|\[BOTH\]|\[smt\]|\[rbmt\]|\[both\]//g; 
      $fraseclean =~ s/\s+/ /g;
      $trans[0] =~ s/\s//g;
      my $suma =$frase_ant+1;
      if ($trans[0] == $suma) {
# 	 print OUTbleu "$bestB\n";
 	 print OUTter "$bestT\n";
         $target = <REF>;
         chomp($target);
         $frase_ant = $trans[0];
	 $bleu_ant=0; 
	 $bleu=0; 	
	 $bestB=$trans[1];
	 $ter_ant=99999999; 
	 $ter=99999999; 
	 $bestT=$trans[1];
         Matxin::Common::show_progress($frase_ant, $Matxin::Common::progress0, $Matxin::Common::progress1);
      }

#if ($frase_ant>-1){
#      $bleu_ant = Metrics::calculaSbleu($fraseclean,$target);
#      
#      if ($bleu_ant > $bleu) {
#         $bleu=$bleu_ant;
#         $bestB=$trans[1];
#      }
#}

if ($frase_ant>1000){
      if ($fraseclean eq ' '){$fraseclean='.';} #xapussa
      $ter_ant = Metrics::calculaTercom($fraseclean,$target,$frase_ant);
      if ($ter_ant < $ter) {
   	 $ter=$ter_ant;
	 $bestT=$trans[1];
      }
}
   $i++;
}

# print OUTbleu "$bestB\n";
print OUTter "$bestT\n";


close(IN);
#close(OUTbleu);
close(OUTter);
close(REF);

