package Matxin::Alternative;

use Modern::Perl;
use Matxin::Common;

sub new {
    #description _ creates a new Matxin::Alternative object (class constructor) out from a given alternative twig element
    #              (which is a sequence of translation alternatives)
    #param1 _ alternative element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $ALTERNATIVE = shift;
    my $verbose = shift;

    my $alternative = { align => Matxin::Common::get_attribute_value($ALTERNATIVE, 'align'),
                        confidence => Matxin::Common::get_attribute_value($ALTERNATIVE, 'confidence'),
                        ord => Matxin::Common::get_attribute_value($ALTERNATIVE, 'ord'),
                        translation => Matxin::Common::get_attribute_value($ALTERNATIVE, 'translation'),
#                        translation => Matxin::Common::get_attribute_value($ALTERNATIVE, 'Analyzed'),       # cris lm
                        system => Matxin::Common::get_attribute_value($ALTERNATIVE, 'system'),
                        ibms => Matxin::Common::get_attribute_value($ALTERNATIVE, 'IBM'),
                        dicts => Matxin::Common::get_attribute_value($ALTERNATIVE, 'Dict'),
                        chunkOK => Matxin::Common::get_attribute_value($ALTERNATIVE, 'Chunk'),
                        chunkDist => Matxin::Common::get_attribute_value($ALTERNATIVE, 'Chunk-dist'),
                        chunkTypes => Matxin::Common::get_attribute_value($ALTERNATIVE, 'ChunkType')
    };

    bless $alternative, $class;

    return $alternative;
}

sub ord {
    #description _ returns translation order
    #param1  _ alternative (implicit)
    #@return _ translation order 
	
    my $alternative = shift;
	
    return $alternative->{ord};
}

sub translation {
    #description _ returns translation text
    #param1  _ alternative (implicit)
    #@return _ translation text 

    my $alternative = shift;
	
    return $alternative->{translation};
}

sub align {
    #description _ returns translation alignments wrt the source
    #param1  _ alternative (implicit)
    #@return _ alignments

    my $alternative = shift;
	
    return $alternative->{align};
}

sub system {
    #description _ returns the system from where the translation comes from
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{system};
}

sub ibms {
    #description _ returns the string with ibms scores
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{ibms};
}

sub dicts {
    #description _ returns the string with the dictionary scores
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{dicts};
}

sub chunkOK {
    #description _ returns a binary indicating if the chunk is syntactic or not
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{chunkOK};
}


sub chunkDist {
    #description _ returns the string with a real [-1,1] measure of the number of chunks in both languages
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{chunkDist};
}

sub chunkTypes {
    #description _ returns the string with 7 scores (1,-1,0) corresponding to 7 types of chunks (SMT, RBMT, none)
    #param1  _ alternative (implicit)
    #@return _ procedence system

    my $alternative = shift;
	
    return $alternative->{chunkTypes};
}


1;
