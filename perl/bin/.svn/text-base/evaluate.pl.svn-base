#!/usr/bin/perl -w

#################################################################
# Description 
# Prepara els fitxers en format per BLEU i TER i els evalua
#################################################################

use strict;

# Check program arguments, and other initializations
my $argc = @ARGV;
if ($argc != 1) { die("\n Us: $0 <file>\n\n");}

my $IN = "$ARGV[0]";
my $dosRefs = 0;
my ($refFile, $refFileA, $refFileB, $refFileTerA);

my $random = rand();
if ($dosRefs){
    $refFile='/home/cristina/pln/devSoft/emt/data/SMatxinT0/NEWStest.eu1.tok.';
    $refFileA='/home/cristina/pln/devSoft/emt/data/SMatxinT0/NEWStest.eu1.tok.0';
    $refFileB='/home/cristina/pln/devSoft/emt/data/SMatxinT0/NEWStest.eu1.tok.1';
    $refFileTerA='refterA'.$random;
}else{
    $refFile='/home/cristina/pln/devSoft/emt/data/SMatxinT0/EITBtest.eu.tok';
    $refFileTerA='refterA'.$random;
}

my $refFileTer='refter'.$random;
my $bleu = "/home/cristina/soft/mosesdecoder/scripts/generic/multi-bleu.perl";
my $ter = "/home/cristina/pln/devSoft/emt/exp/hybrid/tercom_v6b.pl";


open(IN,"< $IN") || die("\n No es pot obrir el fitxer $IN\n\n");
open(OUTbleu,"> $IN.bleu") || die("\n No es pot crear el fitxer $IN.bleu\n\n");
open(OUTter,"> $IN.ter") || die("\n No es pot crear el fitxer $IN.ter\n\n");
open(REFter,"> $refFileTer") || die("\n No es pot crear el fitxer $refFileTer\n\n");
if ($dosRefs){ 
   open(REFterA,"> $refFileTerA") || die("\n No es pot crear el fitxer $refFileTerA\n\n");
   open(REFA,"< $refFileA") || die("\n No es pot obrir el fitxer $refFileA\n\n");
   open(REFB,"< $refFileB") || die("\n No es pot obrir el fitxer $refFileB\n\n");
} else {
   open(REFB,"< $refFile") || die("\n No es pot obrir el fitxer $refFile\n\n");
}

my $count=0;
while(<IN>){
    chomp;
    my $sentence=$_;
    $sentence = lc($sentence);
    $sentence =~ s/\[SMT\]|\[RBMT\]|\[BOTH\]|\[CD\]|\[smt\]|\[rbmt\]|\[both\]|\[cd\]//g; 
    print OUTbleu "$sentence\n";
    print OUTter "$sentence ($count)\n";
    my $ref = <REFB>;
    chomp($ref);
    print REFter "$ref ($count)\n";

    if ($dosRefs){ 
       my $refA = <REFA>;
       chomp($refA);
       print REFterA "$refA ($count)\n";
    }
    $count++;
}

close(IN);
close(OUTbleu);
close(OUTter);
#close(REF);
close(REFter);
close(REFA);
close(REFterA);
close(REFB);

system("perl $bleu $refFile < $IN.bleu > $IN.scoreBLEU");
if ($dosRefs){
    system("perl $ter -h $IN.ter -r $refFileTer -a $refFileTerA -N");
}else {
    system("perl $ter -h $IN.ter -r $refFileTer -N");
}
	
system("rm $IN.bleu $IN.ter $refFileTer $refFileTerA *sys.pra *sys.sum *sys.sum_nbest");


