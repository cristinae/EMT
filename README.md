# EMT

### Description
EMT is designed as a part of the SMatxinT system, a hybrid architecture which combines 
rule-based machine translation (RBMT) with phrase-based statistical machine translation (SMT).

The input for EMT is an xml file with a *traslation tree*. For each source sentence, it 
contains a tree with chunk elements with the source text, the translation of the RBMT system
and an *n*-best list of SMT translations for every chunk and nested subchunks. Several attributes
describing the source and the translations are included.

EMT combines all this information to build a translation table that can be used in an SMT
system. It extracts the phrase-pairs corresponding to the chunks at all levels of nesting 
(from leaves to the full sentence) and to all the individual translation systems involved.
Additional features with respect to the nature of the sistems are then included into the 
phrase table.

### Usage
```sh
 
  mockPhraseTable.pl [options] <xml_file>
  Options:
   -max_rbmt <n>: maximum number of alternative RBMT node translations (1 by default)
   -max_smt <n> : maximum number of alternative SMT chunk translations (1 by default)
   -c           : include Context Discriminated SMT translations (0/1)
   -p           : number of parts to divide the test set
   -o           : output path
   -t           : keep trace of the system in the TT (0/1)
   -v           : verbosity
   -help        : this help
  Example:
   perl mockPhraseTable.pl -max_rbmt 1 -max_smt 3 -c 1 -p 1 -t 0  -o <outputFolder> -v <xmlFile>
```

### Reference & Further information
Gorka Labaka, Cristina España-Bonet, Lluís Màrquez, Kepa Sarasola. 
*A hybrid machine translation architecture guided by syntax*.
Machine Translation Journal, Vol. 28, Issue 2, pages 91-125, October, 2014. 

#### TODO
Write a DTD for the input XML files

### Authors
Jesús Giménez and Cristina España-Bonet

