#!/usr/bin/perl -w

my $refFileB='/home/cristina/pln/devSoft/emt/data/SMatxinT/ADMINtest.eu.tok';
my $bleu = "/home/cristina/soft/moses/trunk/scripts/generic/multi-bleu.perl";
my $IN = "/home/cristina/pln/sistemes/matxin/concens1.5.c/testADMIN/ADMINtest.devEITB.oracleBLEU2";

system("perl $bleu $refFileB < $IN > $IN.scoreBLEU22")
