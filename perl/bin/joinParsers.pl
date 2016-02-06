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
if ($argc != 2) { die("\n Us: $0 <nbest file>  <nbest file2>\n\n");}

my $IN1 = "$ARGV[0]";
my $IN2 = "$ARGV[1]";
my $FileMix = $IN1;
my $FileBest = $IN1; 
$FileMix =~ s/\.nbest10000\.SMatxinT\.eutrad/\.nbest.mix/;
$FileBest =~ s/\.nbest10000\.SMatxinT\.eutrad/\.1best.mix/;

open(IN1,"< $IN1") || die("\n No es pot obrir el fitxer $IN1\n\n");
open(IN2,"< $IN2") || die("\n No es pot obrir el fitxer $IN2\n\n");

open(OUTmix,"> $FileMix") || die("\n No es pot crear el fitxer $FileMix\n\n");
open(OUTbest,"> $FileBest") || die("\n No es pot crear el fitxer $FileBest\n\n");

my $frase_ant1 = 0;
my $frase_ant2 = 0;
my $i=0;
my $j=0;

my $best1='';
my $best2='';
my $best1score=0;
my $best2score=0;
my $best1_ant=''; 
my $best1score_ant=0;
my $trans_ant='';
my $l2='';
while (my $l = <IN1>){
      chomp($l);
      my @trans = split(/ \|\|\| /, $l);

      if ($i==0) {$best1=$l; $best1score=$trans[3];}

      my $suma =$frase_ant1+1;
      if ($trans[0] == $suma) {
         $frase_ant1 = $trans[0];
	 $trans_ant=$trans[1]; 
	 $best1score_ant=$best1score;
	 $best1=$l; 
	 $best1score=$trans[3];


	 while ($l2 = <IN2>){
           chomp($l2);
      	   my @trans2 = split(/ \|\|\| /, $l2);
           my $suma2 = $frase_ant2+1;

           if ($j==0) {
		$best2=$l2; 
		$best2score=$trans2[3];
	       if($best2score>=$best1score){
		print OUTbest "$trans2[1]\n";
	       }else{
		print OUTbest "$trans[1]\n";
	       }
	   }

	   if ($trans2[0] == $suma2) {
	       $best2=$l2; 
	       $best2score=$trans2[3];
               $frase_ant2 = $trans2[0];
	       if($best2score>=$best1score_ant){
		print OUTbest "$trans2[1]\n";
	       }else{
		print OUTbest "$trans_ant\n";
	       }
		last;
	   }

           print OUTmix "$l2\n";
	   $j++;
	 }
	
         Matxin::Common::show_progress($frase_ant1, $Matxin::Common::progress0, $Matxin::Common::progress1);
      }

    print OUTmix "$l\n";
    $i++;
}

print OUTmix "$l2\n";
while ($l2 = <IN2>){
     chomp($l2);
     print OUTmix "$l2\n";
}

close(IN1);
close(IN2);
close(OUTmix);
close(OUTbest);

