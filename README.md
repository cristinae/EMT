# EMT

## Description:
EMT is designed as a part of the SMatxinT system, a hybrid architecture which combines 
rule-based machine translation (RBMT) with phrase-based statistical machine translation (SMT).

The input for EMT is an xml file with a *traslation tree*. For each source sentence, it 
contains a tree with chunk elements with the source text, the translation of the RBMT system
and an n-best list of SMT translations for every chunk and nested subchunks. Several attributes
describing the source and the translations are included.

EMT combines all this information to build a translation table that can be used in an SMT
system. It extracts the phrase-pairs corresponding to the chunks at all levels of nesting 
(from leaves to the full sentence) and to all the individual translation systems involved.
Additional features with respect to the nature of the sistems are then included into the 
phrase table.

## Usage:
perl  emt/perl/bin/mockPhraseTable.pl -max_rbmt 1 -max_smt 3 -c 1 -p 1 -t 0 
      -o <outputFolder> -v <xmlFile>

## Reference & Further information:
*A hybrid machine translation architecture guided by syntax*  
Gorka Labaka, Cristina España-Bonet, Lluís Màrquez, Kepa Sarasola  
Machine Translation Journal, Vol. 28, Issue 2, pages 91-125, October, 2014. 

## TODO:
Write a DTD for the input XML files

## Authors:
Jesús Giménez and Cristina España-Bonet

