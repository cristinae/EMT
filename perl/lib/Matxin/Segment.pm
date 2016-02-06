package Matxin::Segment;

use Modern::Perl;
use XML::Twig;
use Data::Dumper;
use Matxin::Common;
use Matxin::Sentence;

sub new {
    #description _ creates a new Matxin::Segment object (class constructor) out from a given XML file
    #param1 _ segment element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $SEGMENT = shift;
    my $verbose = shift;

    my $segment = { ord => Matxin::Common::get_attribute_value($SEGMENT, 'ord'),
                    sentences => {},
                    LocalAltTrans => undef
    };

    bless $segment, $class;

    my @CONTENTS = $SEGMENT->children;
    foreach my $content (@CONTENTS) {
       if ($content->gi() eq $Matxin::Common::SENTENCE_LABEL) { $segment->add_sentence($content, $verbose); }
       elsif ($content->gi() eq $Matxin::Common::LocalAltTrans_LABEL) { $segment->set_LocalAltTrans($content, $verbose); }
    }

    return $segment;
}

sub add_sentence {
    #description _ stores a new sentence into the segment
    #param1 _ segment reference  (implicit)
    #param2 _ sentence element
    #param3 _ verbosity

    my $segment = shift;
    my $SENTENCE = shift;
    my $verbose = shift;

    my $sentence = new Matxin::Sentence($SENTENCE, $verbose);
    $segment->{sentences}->{$sentence->ord()} = $sentence;
}

sub set_LocalAltTrans {
    #description _ stores the LocalAltTrans in the segment (overwrites previous value)
    #param1 _ segment reference  (implicit)
    #param2 _ LocalAltTrans element
    #param3 _ verbosity

    my $segment = shift;
    my $TRANS = shift;
    my $verbose = shift;

    $segment->{LocalAltTrans} = new Matxin::Translation($TRANS, $verbose);
}

sub sentences {
    #description _ returns the list of sentences in the segment (sorted by ord, ASC)
    #param1  _ segment reference  (implicit)
    #@return _ chunk list ref

    my $segment = shift;
        
    my @values;
    foreach my $ord (sort {$a <=> $b} keys %{$segment->{sentences}}) { push(@values, $segment->{sentences}->{$ord}); }
    
    return \@values; 
}

sub ord {
    #description _ returns the segment order (ord attribute)
    #param1  _ segment reference  (implicit)
    #@return _ ord value

    my $segment = shift;

    return $segment->{ord};
}

sub get_LocalAltTrans_string_list {
    #description _ retrieves the LocalAltTrans string list in the segment
    #param1  _ segment reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ LocalAltTrans list ref

    my $segment = shift;
    my $max_alternatives = shift;    

    return $segment->{LocalAltTrans}->alternatives($max_alternatives);
}

sub get_LocalAltTransSyst_string_list {
    #description _ retrieves the LocalAltTrans string list in the segment
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve the alternatives from
    #@return _ LocalAltTrans list ref

    my $segment = shift;
    my $max_alternatives = shift;    
    my $system = shift;    

    return $segment->{LocalAltTrans}->alternatives_systems($max_alternatives,$system);
}

sub get_LocalAltTransFEATsSyst_string_list {
    #description _ retrieves the IBM scores for LocalAltTrans string list in the segment
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ LocalAltTrans list ref

    my $segment = shift;
    my $max_alternatives = shift;    
    my $system = shift;    

    return $segment->{LocalAltTrans}->features_systems($max_alternatives,$system);
}


1;
