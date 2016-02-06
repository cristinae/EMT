#!/usr/bin/perl -w

#################################################################
# Description 
# Agafa la sortida nbestlist de moses amb aliniaments i passa 
# aquests aliniaments al format de moses per la millor sortida.
#################################################################

use strict;
use Metrics;
use Matxin::Common;
use Data::Dumper;

# Check program arguments, and other initializations
my $argc = @ARGV;
if ($argc != 2) { die("\n Us: $0 <nbest file> <oracle>\n\n");}

my $IN = shift(@ARGV);
my $oracle = shift(@ARGV);

my $outOracle = $oracle.'LABEL';

open(IN,"< $IN") || die("\n No es pot obrir el fitxer $IN\n\n");
open(ORC,"< $oracle") || die("\n No es pot obrir el fitxer $oracle\n\n");
open(OUT,"> $outOracle") || die("\n No es pot crear el fitxer $outOracle\n\n");

my $i=0;
my $k=0;

my $best = <ORC>; 
chomp($best);
my $espais = $best =~ s/\s+/ /g;
while (my $l = <IN>){
      chomp($l);
      my @trans = split(/ \|\|\| /, $l);
      my $fraseclean = $trans[1];    
      my $aliniament = $trans[-1];
#      $fraseclean =~ s/\'/\\\'/g;
      $fraseclean =~ s/\[SMT\]|\[CD\]|\[RBMT\]|\[BOTH\]|\[smt\]|\[cd\]|\[rbmt\]|\[both\]//g; 
      $fraseclean =~ s/\s+/ /g;

      my $output;	
      my $prova = '\Q'.$fraseclean.'\E';  #semblaria que no pero es necessari
      if ($fraseclean =~ /\Q$best\E/) {

	 #print "$fraseclean\n$best\n\n";
         my @words = split(/\s+/,$fraseclean);
         my @aliniaments = split(/\s+/,$aliniament);

         #if ($i==223521||$i==2156029||$i==3519193||$i==4471568||$i==4794072) {
          #   print "\n$fraseclean\n$best\nespais: $espais\n\n"; print Dumper @words;print Dumper @aliniaments;<STDIN>;}
         $output = '';
	 foreach my $tros (@aliniaments){
            my $sourcePos;
            my $targetIni; 
            my $targetFi;
	    if ($tros =~ /(\d+)\-(\d+)=(\d+)\-(\d+)/) {
            	$sourcePos = '|'.$1.'-'.$2.'|';
            	$targetIni = $3;
            	$targetFi = $4;
            } elsif ($tros =~ /(\d+)=(\d+)\-(\d+)/) {
            	$sourcePos = '|'.$1.'-'.$1.'|';
            	$targetIni = $2;
            	$targetFi = $3;
            } elsif ($tros =~ /(\d+)\-(\d+)=(\d+)/) {
            	$sourcePos = '|'.$1.'-'.$2.'|';
            	$targetIni = $3;
            	$targetFi = $3;
            } elsif ($tros =~ /(\d+)=(\d+)/) {
            	$sourcePos = '|'.$1.'-'.$1.'|';
            	$targetIni = $2;
            	$targetFi = $2;
	    }
            if ($targetFi>100){$targetFi=$targetIni;} #xapussa per tractar aliniaments dolents (phrases X -> buit?)
	    my $j;
            for($j=0; $j<=$targetFi-$targetIni; $j++){
		$output .= $words[$targetIni+$j].' ';
            }
 	    $output .= $sourcePos.' ';
         }
         print OUT "$output\n";  
	 $k++;       
         $best = <ORC>;
         if (!$best) {last;}
         chomp($best);
	 $espais = $best =~ s/\s+/ /g;
         Matxin::Common::show_progress($k, $Matxin::Common::progress0, $Matxin::Common::progress1);
      }
    $i++;
}



close(IN);
close(OUT);
close(ORC);

