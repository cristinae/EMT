#!/usr/bin/perl -w

#################################################################
# Description 
# Agafa un test amb informacio de segmentacio i la substitueix
# per la informacio del sistema de procedencia
#################################################################

use strict;
use Data::Dumper;

# Check program arguments, and other initializations
#my $argc = @ARGV;
#if ($argc != 1) { die("\n Us: $0 <test>\n\n");}

#my $IN = "$ARGV[0]";
#my $OUT = $IN.'moses';

#my $test='EITBdev.dev.oracleBLEU.aligns';
#my $src='test.EITBdevel.2011_05_26.SMatxinT.1';
#my $tt='phrase-table.EITBdevel.2011_05_26.SMatxinT.TRACA';
#my $OUT='EITBdev.dev.oracleBLEU.LABEL';

my $set = 'NEWS';
my $test=''.$set.'testcnsDist.devADMINt2.nbest1.SMatxinT.eutrad';
#my $test=$set.'testbase.devADMINt1.oracleDistBLEU.align';
my $src='test.'.$set.'test.2013_05_16.SMatxinT';
my $tt='phrase-table.'.$set.'test.2013_05_16.SMatxinT';
#my $OUT='test.'.$set.'test.SMatxinTPL50.eutrad.labeled';
my $OUT=$test.'.labeled';



open(TT,"< $tt") || die("\n No es pot obrir el fitxer $tt\n\n");
open(TEST,"< $test") || die("\n No es pot obrir el fitxer $test\n\n");
open(SRC,"< $src") || die("\n No es pot obrir el fitxer $src\n\n");
open(OUT,"> $OUT") || die("\n No es pot crear el fitxer $OUT\n\n");

my %table;
while(<TT>){
    chomp;
    my $line=$_;
#    $line =~ /^(.+) \|\|\| (.+) \|\|\| (.+)/;
    $line =~ /^(.+ \|\|\|.+) (\[\w{2,4}\]) \|\|\| .+/;
    my $phrase = $1;
    my $label = $2;
    $phrase =~ s/\s+/ /g;
    $table{$phrase}=$label;
}

my $phrasesSMT=0;
my $phrasesCD=0;
my $phrasesSMTtot=0;
my $phrasesRBMT=0;
my $phrasesBOTH=0;
my $wordsSMT=0;
my $wordsSMTtot=0;
my $wordsCD=0;
my $wordsRBMT=0;
my $wordsBOTH=0;
my $wholeSMT=0;
my $wholeRBMT=0;
my $wholeBOTH=0;

while(<TEST>){
    chomp;
    my $line=$_;
    my ($number, $trad, $features, $score, $alignments) = split(/\|\|\|/,$line);

    $alignments =~ s/^\s+//;
    $alignments =~ s/\s+$//;
    
    my @pairs;
    my $whole=0;
    if ($alignments  =~ /^(\d+-)*\d+=\d+(-\d+)*$/){
       $pairs[0]=$alignments;
       $whole=1;
    }else{
       @pairs = split(/\s+/,$alignments);
    }
    $trad =~ s/^\s+//;
    $trad =~ s/\s+$//;
    my @wordsT = split(/\s+/,$trad);

    my $sourceF = <SRC>;
    chomp($sourceF);
    my @wordsS = split(/\s+/,$sourceF);

    my ($Sini, $Sfi, $Tini, $Tfi);
    foreach my $pair (@pairs) {
#	print $pair;<STDIN>;
       if ($pair =~ /(\d+)-(\d+)=(\d+)-(\d+)/) {
       	    $Sini = $1;
            $Sfi = $2;
            $Tini = $3;
            $Tfi = $4;
	}elsif($pair =~ /(\d+)=(\d+)-(\d+)/) {
       	    $Sini = $1;
            $Sfi = $1;
            $Tini = $2;
            $Tfi = $3;
	}elsif($pair =~ /(\d+)-(\d+)=(\d+)/) {
       	    $Sini = $1;
            $Sfi = $2;
            $Tini = $3;
            $Tfi = $3;
	}elsif($pair =~ /(\d+)=(\d+)/) {
       	    $Sini = $1;
            $Sfi = $1;
            $Tini = $2;
            $Tfi = $2;
	}


       my $target ='';
       for (my $i = $Tini; $i <= $Tfi; $i++) {
 	   $target .= $wordsT[$i].' ';
       }
       $target =~ s/\s+$//;
       my $source='';
       for (my $i = $Sini; $i <= $Sfi; $i++) {
 	   $source .= $wordsS[$i].' ';
       }
       $source =~ s/\s+$//;
       my $key = $source.' ||| '.$target; 
       my $label = $table{$key};
#       print "key: $key   label: $table{$key} \n";
       print OUT "$target $label ";

       if ($label =~ /\[smt/){
	 $phrasesSMT++;
	 $wholeSMT++ if $whole;
	 $wordsSMT = $wordsSMT+$Tfi-$Tini+1; 
       }elsif ($label =~ /\[cd/){
	 $phrasesCD++;
	 $wordsCD = $wordsCD+$Tfi-$Tini+1; 
	 $wholeSMT++ if $whole;
       }elsif ($label =~ /\[rbmt/){
#	print "HELLO";<STDIN>;
	 $phrasesRBMT++;
	 $wordsRBMT = $wordsRBMT+$Tfi-$Tini+1; 
	 $wholeRBMT++ if $whole;
       }elsif ($label =~ /\[both/){
	 $phrasesBOTH++;
	 $wordsBOTH = $wordsBOTH+$Tfi-$Tini+1; 
	 $wholeBOTH++ if $whole;
       }
    } #fi mypair
    print OUT "\n";
}
    $phrasesSMTtot = $phrasesSMT + $phrasesCD;
    $wordsSMTtot = $wordsSMT + $wordsCD;

    my $phrasesTot =  $phrasesSMTtot + $phrasesRBMT + $phrasesBOTH;
    my $wordsTot =  $wordsSMTtot + $wordsRBMT + $wordsBOTH;


    #per al paper
    #printf "%.2f & %.2f & %.2f &  \n\n", $wordsSMTtot/$phrasesSMTtot, $wordsRBMT/$phrasesRBMT, $wordsBOTH/$phrasesBOTH;


    printf "\n\n$phrasesSMT (%.1f\\%%) & $phrasesCD (%.1f\\%%)  & $phrasesRBMT (%.1f\\%%)  & $phrasesBOTH (%.1f\\%%) &", $phrasesSMT*100/$phrasesTot, $phrasesCD*100/$phrasesTot,$phrasesRBMT*100/$phrasesTot, $phrasesBOTH*100/$phrasesTot;
    printf "$wordsSMT (%.1f\\%%) & $wordsCD (%.1f\\%%)  & $wordsRBMT (%.1f\\%%) & $wordsBOTH (%.1f\\%%)  \\\\ \n", $wordsSMT*100/$wordsTot, $wordsCD*100/$wordsTot,$wordsRBMT*100/$wordsTot, $wordsBOTH*100/$wordsTot;
    printf "%.2f &  %.2f & %.2f & %.2f &  ", $wordsSMT/$phrasesSMT, $wordsCD/$phrasesCD,$wordsRBMT/$phrasesRBMT, $wordsBOTH/$phrasesBOTH;
    printf "%d &  %d & %d  \\\\ \n\n\n", $wholeSMT, $wholeRBMT, $wholeBOTH;

#    print "\n\n$phrasesSMT (".$phrasesSMT*100/$phrasesTot."\%) & $phrasesCD (".$phrasesCD*100/$phrasesTot."\%)  & $phrasesRBMT (".$phrasesRBMT*100/$phrasesTot."\%)  & $phrasesBOTH (".$phrasesBOTH*100/$phrasesTot."\%)  \n";
#    print "\n$wordsSMT (".$wordsSMT*100/$wordsTot."\%) & $wordsCD (".$wordsCD*100/$wordsTot."\%)  & $wordsRBMT (".$wordsRBMT*100/$wordsTot."\%)  & $wordsBOTH (".$wordsBOTH*100/$wordsTot."\%) \\\\ \n\n\n";


close(TT);
close(TEST);
close(SRC);
close(OUT);
