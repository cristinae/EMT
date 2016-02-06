package Matxin::Translation;

use Modern::Perl;
use Data::Dumper;
use Matxin::Common;
use Matxin::Alternative;

sub new {
    #description _ creates a new Matxin::Translation object (class constructor) out from a given node twig element
    #              (which is a sequence of chunks)
    #param1 _ node element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $TRANSLATION = shift;
    my $verbose = shift;

    my $translation = { 
			source => Matxin::Common::get_attribute_value($TRANSLATION, 'source'),
#			source => Matxin::Common::get_attribute_value($TRANSLATION, 'indexed_source'),
                        alternatives => [],
                        alignments => []
    };

    bless $translation, $class;

    #print "        --> $source\n";

    my @ALTERNATIVES = $TRANSLATION->children;
    foreach my $alternative (@ALTERNATIVES) { 
	$translation->add_alternative($alternative, $verbose); 
    }

    return $translation;
}

sub add_alternative {
    #description _ pushes a new alternative into the translation
    #param1 _ translation reference  (implicit)
    #param2 _ alternative element
    #param3 _ verbosity

    my $node = shift;
    my $ALTERNATIVE = shift;
    my $verbose = shift;

    push(@{$node->{alternatives}}, new Matxin::Alternative($ALTERNATIVE, $verbose));
}

sub alternatives {
    #description _ retrieves the list alternative translations in the ChunkTranslation
    #param1  _ translation reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ alternative translation list ref

    my $translation = shift;
    my $max_alternatives = shift;    
	
    my $i = 0;
    my @alternative_translations;
    while (($i < scalar(@{$translation->{alternatives}})) and
       (scalar(@alternative_translations) < $max_alternatives)) {
       if ($translation->{alternatives}->[$i]->ord() < $max_alternatives) {
   	  push(@alternative_translations, $translation->{alternatives}->[$i]->translation());
       }
       $i++;
    }
	
    return \@alternative_translations;
}

sub alternatives_systems {
    #description _ retrieves the list alternative translations in the ChunkTranslation for a given system
    #param1  _ translation reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve translations from 
    #@return _ alternative translation list ref

    my $translation = shift;
    my $max_alternatives = shift;   
    my $system = shift; 
	
    my $i = 0;
    my @alternative_translations;
    while (($i < scalar(@{$translation->{alternatives}})) and (scalar(@alternative_translations) < $max_alternatives)) {
       my $system_atribut = $translation->{alternatives}->[$i]->system();
       if (($translation->{alternatives}->[$i]->ord() < $max_alternatives) && ($system_atribut =~ /^$system/)) {
   	  push(@alternative_translations, lc($translation->{alternatives}->[$i]->translation()));
       }
       $i++;
    }
	
    return \@alternative_translations;
}

sub ibms_systems {
    #description _ retrieves the list of IBMs features in the ChunkTranslation for a given system
    #param1  _ translation reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve features from 
    #@return _ ibms list ref

    my $translation = shift;
    my $max_alternatives = shift;   
    my $system = shift; 
	
    my $i = 0;
    my @alternative_translations_ibms;
    while (($i < scalar(@{$translation->{alternatives}})) and
       (scalar(@alternative_translations_ibms) < $max_alternatives)) {
       my $system_atribut = $translation->{alternatives}->[$i]->system();
       if (($translation->{alternatives}->[$i]->ord() < $max_alternatives) && ($system_atribut =~ /^$system/)) {
   	  push(@alternative_translations_ibms, $translation->{alternatives}->[$i]->ibms());
       }
       $i++;
    }
	
    return \@alternative_translations_ibms;
}

sub features_systems {
    #description _ retrieves the list of features (IBMs, Dict & Chunck) in the ChunkTranslation for a given system
    #param1  _ translation reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve features from 
    #@return _ ibms list ref

    my $translation = shift;
    my $max_alternatives = shift;   
    my $system = shift; 
	
    my $i = 0;
    my @alternative_translations_feats;
    while (($i < scalar(@{$translation->{alternatives}})) and
       (scalar(@alternative_translations_feats) < $max_alternatives)) {
       my $system_atribut = $translation->{alternatives}->[$i]->system();
       if (($translation->{alternatives}->[$i]->ord() < $max_alternatives) && ($system_atribut =~ /^$system/)) {
   	  my $f_ibm = $translation->{alternatives}->[$i]->ibms();
   	  my $f_dict = $translation->{alternatives}->[$i]->dicts();
   	  my $f_Cok = $translation->{alternatives}->[$i]->chunkOK();
   	  my $f_Cdist = $translation->{alternatives}->[$i]->chunkDist();
   	  my $f_Ctypes = $translation->{alternatives}->[$i]->chunkTypes();

	  $f_Ctypes = addConcensChunk($f_Ctypes); #only works for a given set of features (6 = 3SMT+3RBMT -> 9)

	  my $feats = $f_ibm.' '.$f_dict.' '.$f_Cok.' '.$f_Cdist.' '.$f_Ctypes;    #cris
#	  my $feats = ' ';
#	  my $feats = $f_ibm.' '.$f_dict;
#	  my $feats = $f_Cok.' '.$f_Cdist.' '.$f_Ctypes;
   	  push(@alternative_translations_feats, $feats);
       }
       $i++;
    }
	
    return \@alternative_translations_feats;
}



sub addConcensChunk {
    #description _ from an array with 3 features corresponding to SMT and 3 corresponding to Matxin, 
    #              estimates the 3 corresponding concensus features
    #param1  _ array of features input
    #@return _ array with the additional features

    my $features = shift;
    my @feature = split(/\s+/, $features);


    my $newFeatures = $features;
    if ($feature[0]==$feature[3]) { 
	$newFeatures = $newFeatures.' '.$feature[0];
    }else{
	$newFeatures = $newFeatures.' 1';
    }
    if ($feature[1]==$feature[4]) { 
	$newFeatures = $newFeatures.' '.$feature[1];
    }else{
	$newFeatures = $newFeatures.' 1';
    }
    if ($feature[2]==$feature[5]) { 
	$newFeatures = $newFeatures.' '.$feature[2];
    }else{
	$newFeatures = $newFeatures.' 1';
    }

    return $newFeatures;
}



sub alignments {
    #description _ retrieves the list of alignments in the ChunkTranslation
    #param1  _ translation reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ alternative translation alignments list ref

    my $translation = shift;
    my $max_alternatives = shift;    
	
    my $i = 0;
    my @alternative_translations_alignments;
    while (($i < scalar(@{$translation->{alternatives}})) and
       (scalar(@alternative_translations_alignments) < $max_alternatives)) {
       if ($translation->{alternatives}->[$i]->ord() < $max_alternatives) {
   	  push(@alternative_translations_alignments, $translation->{alternatives}->[$i]->align());
       }
       $i++;
    }
	
    return \@alternative_translations_alignments;
}


sub get_source {
    #description _ returns the source
    #param1  _ translation  (implicit)
    #@return _ source attribute 

    my $translation = shift;

    return $translation->{source};
}

1;
