package Matxin::Common;

use Modern::Perl;
use Data::Dumper;

use vars qw($CORPUS_LABEL $SENTENCE_LABEL $CHUNK_LABEL $NODE_LABEL $SYN_LABEL $FullAltTrans_LABEL $LocalAltTrans_LABEL $Alterntive_LABEL $EMPTY_ITEM $max_alternatives_node_DEFAULT $max_alternatives_trans_DEFAULT $parts_DEFAULT $SMT_LABEL $RBMT_LABEL $e);

# ---------------------------------                 #XML element labels
$Matxin::Common::CORPUS_LABEL = "CORPUS";
$Matxin::Common::SENTENCE_LABEL = "SENTENCE";
$Matxin::Common::CHUNK_LABEL = "CHUNK";
$Matxin::Common::NODE_LABEL = "NODE";
$Matxin::Common::SYN_LABEL = "SYN";
$Matxin::Common::FullAltTrans_LABEL = "FullAltTrans";
$Matxin::Common::LocalAltTrans_LABEL = "LocalAltTrans";
$Matxin::Common::Alternative_LABEL = "Alternative";
#$Matxin::Common::_LABEL = "";
$Matxin::Common::EMPTY_ITEM = "***EMPTY***";
$Matxin::Common::baseline = "baseline";
$Matxin::Common::CDbaseline = "CD-baseline-";
$Matxin::Common::generation = "generation";
$Matxin::Common::CDgeneration = "CD-generation-";
$Matxin::Common::RBMT = "RBMT";
# ---------------------------------                 #systems
$Matxin::Common::SMT_LABEL = "[smt]";
$Matxin::Common::RBMT_LABEL = "[rbmt]";
$Matxin::Common::CD_LABEL = "[cd]";                 #context disambiguated within SMT
$Matxin::Common::BOTH_LABEL = "[both]";             
# ---------------------------------                 #max alternatives
$Matxin::Common::max_alternatives_node_DEFAULT = 1;
$Matxin::Common::max_alternatives_trans_DEFAULT = 1;
$Matxin::Common::parts_DEFAULT = 1;
$Matxin::Common::trace_DEFAULT = 1;
$Matxin::Common::cd_DEFAULT = 1;
# ---------------------------------                 #progress values
$Matxin::Common::progress0 = 1;
$Matxin::Common::progress1 = 10;
$Matxin::Common::progress2 = 100;
$Matxin::Common::progress3 = 1000;
# ---------------------------------                 #numerical constants
$Matxin::Common::e = 2.718;
$Matxin::Common::one = 1;


sub concatenate_paths {
    #description _ returns all possible concatenations of elements in paths1 and paths2
    #param1 _ input/output paths1 list ref
    #param2 _ input paths2 list ref
	
    my $paths1 = shift;
    my $paths2 = shift;

    if (scalar(@{$paths1}) == 0) { # paths1 list is empty --> copy paths2 list
       @{$paths1} = @{$paths2};
    }
    else { # paths1 list is not empty
       if (scalar(@{$paths2}) != 0) { # paths2 list is not empty --> lists must be concatenated
          my %paths;
          foreach my $t1 (@{$paths1}) {
             foreach my $t2 (@{$paths2}) { 
                 $paths{$t1." ".$t2}++; 
             }
	  }
          @{$paths1} = keys %paths;
       }
    }
}


sub append_phrase_pairs{
    #description _ appends a list of phrase pairs created by combining the given source with the given translation option list (source ||| translation_option_i)
    #param1 _ input/output phrase table hash ref
    #param2 _ input source
    #param3 _ input translation options list ref
    #param4 _ input system type label
    #param5 _ input translation probability list ref (each element on the list is a string with multiple probs)

    my $table = shift;
    my $source = shift;
    my $options = shift;
    my $label = shift;
    my $prob_ref = shift;

    my @prob = @$prob_ref;
    my $i=0;
    foreach my $trad (@{$options}){
        $trad = $trad.' '.$label;
         # adds x per each time the phrase is obtained a system
        if (exists ($table->{$source}->{$trad})) {
	   $table->{$source}->{$trad} .= 'x';
        } else {
  	   $table->{$source}->{$trad} = $prob[$i].' x';
        }

        $i++;
    }
}


sub append_phrase_multiplepairs{
    #description _ appends a list of phrase pairs created by combining the given source with the given translation option list (source ||| translation_option_i)
    #param1 _ input/output phrase table hash ref
    #param2 _ input source array ref
    #param3 _ input translation options list ref
    #param4 _ input system type label
    #param5 _ input translation probability

    my $table = shift;
    my $source = shift;
    my $options = shift;
    my $label = shift;
    my $prob = shift;

    my $i=0;
    foreach my $trad (@{$options}){
        $trad = $trad.' '.$label;
	my $src = @{$source}[$i];
 	$table->{$src}->{$trad} = $prob;
	$i++;
    }
}

sub index_string{
    #description _ indexes every word of a string according to the number of times it has been seen before
    #param1 _ input/output hash reference with the number of occurrences
    #param2 _ input string (usually source) to index
    #@return _ output string (usually source) indexed

    my $word_counts = shift;
    my $string = shift;
    my $indexed_string = '';

    my @words = split(/\s+/, $string);
    foreach my $word (@words){
        my $lc_word = lc($word);
        if ( exists $word_counts->{$lc_word} ) {
            $word_counts->{$lc_word}++;
	}else{
	    $word_counts->{$lc_word}=1;
	}

        if ( $word_counts->{$lc_word}==1) {
           $indexed_string = $indexed_string.$word.' ';
	}else{
           $indexed_string = $indexed_string.$word.'_'.$word_counts->{$lc_word}.' ';
        }
    }

    chop($indexed_string);
    return $indexed_string;
}


sub position_subarray {
    #description _ retrieves the position of a subarray within a larger array
    #nota _ in this case there is no possible multiple matching since strings are indexed
    # JA NO ES VERITAT; MIRAR!! cris
    #param1  _ subarray
    #param2  _ array
    #@return _ intial and final position

    my $subarray = shift;
    my $array = shift;

    my $ini; my $end;
    my $length=scalar @{$subarray};

    my $dins=0;
    my $i=0;
    foreach my $elem_gran (@{$array}) {
	if($dins==1 && $elem_gran eq @{$subarray}[$length-1]){
	   $end=$i;
	   last;
	}elsif($elem_gran eq @{$subarray}[0]){
	   $ini=$i;
	   $dins=1;
           if ($length==1) {$end=$i;last;}
	}
	$i++;
    }

    return ($ini, $end);

}


sub get_attribute_value {
    #description _ retrieve attribute value or empty item if undefined
    #param1  _ XML twig element
    #param2  _ attribute name
    #@return _ attribute value

    my $elem = shift;
    my $attribute = shift;

    my $value = $Matxin::Common::EMPTY_ITEM;
    if (defined($elem->att($attribute))) { $value = $elem->att($attribute); }

    return $value;
}

sub show_progress
{
    #description _ prints progress bar onto standard error output
    #param1 _ iteration number
    #param2 _ print "." after N p1 iterations
    #param3 _ print "#iter" after N p2 iterations

    my $iter = shift;
    my $p1 = shift;
    my $p2 = shift;

    if (($iter % $p1) == 0) { print STDERR "."; }
    if (($iter % $p2) == 0) { print STDERR "$iter"; }
}

sub replace_xml_entities {
    #description _ substitutes xml entities in a given string for its associated actual value.
    #param1  _ input string
    #@return _ output string (free of xml entities)

    my $string = shift;

    $string =~ s/\&amp;/&/g;
    $string =~ s/\&lt;/</g;
    $string =~ s/\&gt;/>/g;
    $string =~ s/\&apos;/\'/g;
    $string =~ s/\&quot;/\"/g;

#    $string =~ s/\|/L/g; # això es per tractar el format moses de manera rapida CRIS

    return $string;
}

sub replace_xml_entities_REV {
    #description _ substitutes conflicting characters in a given string for its associated xml entities.
    #param1  _ input string
    #@return _ output string (free of xml entities)

    my $string = shift;

    $string =~ s/&/\&amp;/g;
    $string =~ s/</\&lt;/g;
    $string =~ s/>/\&gt;/g;
    $string =~ s/\'/\&apos;/g;
    $string =~ s/\"/\&quot;/g;

    #per si de cas ja estava fet
    $string =~ s/\&amp;amp;/\&amp;/g;
    $string =~ s/\&amp;lt;/\&lt;/g;
    $string =~ s/\&amp;gt;/\&gt;/g;
    $string =~ s/\&amp;apos;/\&apos;/g;
    $string =~ s/\&amp;quot;/\&quot;/g;

    return $string;
}



1;
