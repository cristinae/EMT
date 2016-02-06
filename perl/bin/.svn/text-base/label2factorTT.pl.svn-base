#!/usr/bin/perl -w

#################################################################
# Description 
# Converteix el format de TT amb etiquetes al de factors per Moses
#    500 milio [both] administratzeko [smt]
#    500|- milio|- administratzeko|smt
#################################################################

use strict;

# Check program arguments, and other initializations
my $argc = @ARGV;
if ($argc != 1) { die("\n Us: $0 <TT file>\n\n");}

my $IN = "$ARGV[0]";
my $OUT = $IN.'moses';

open(IN,"< $IN") || die("\n No es pot obrir el fitxer $IN\n\n");
open(OUT,"> $OUT") || die("\n No es pot obrir el fitxer $OUT\n\n");

while(<IN>){
    chomp;
    my $phrase=$_;
    $phrase =~ /^(.+) \|\|\| (.+) \|\|\| (.+)/;
    my $source = $1;
    my $target = $2;
    my $scores = $3;

    $source =~ s/\s+/ /g;
    $target =~ s/\s+/ /g;
    $source =~ s/\|/L/g;
    $target =~ s/\|/L/g;

    $target =~ s/ \[(.*)\]/\|$1/;
    $target =~ s/(\S) /$1\|- /g;
#    if ($target!~/^\|/) {
	    print OUT "$source \|\|\| $target \|\|\| $scores\n";
#    }
}

close(IN);
close(OUT);
