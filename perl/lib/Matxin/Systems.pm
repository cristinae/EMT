package Matxin::Systems;

use Modern::Perl;
use XML::Twig;
use Data::Dumper;
use IO::File;
use Matxin::Common;

sub new {
    #description _ creates a new Matxin::System object (class constructor) out from a given Matxin::Segment object
    #param1 _ segment
    #param2 _ segment twig element
    #param3 _ verbosity

    my $class = shift;     #implicit parameter
    my $SEGMENT = shift;
    my $matxin_segment = shift; 
    my $verbose = shift;

    my $systemsTrans = [];
    
    bless $systemsTrans, $class;

    my @SENTENCES = $SEGMENT->children;
    
    #aqui hi ha el sistema 1 (rule based)
    foreach my $sentence (@SENTENCES) {
       if (!defined(@$systemsTrans[0])){  @$systemsTrans[0] = retrieve_RBtranslation($sentence);}
          else {@$systemsTrans[0] = @$systemsTrans[0].' '.retrieve_RBtranslation($sentence);}
    }

    #aqui hi ha el sistema 2 (statistical, el baseline i el generation)
    my $smts =retrieve_SMTtranslation($SEGMENT);
    @$systemsTrans[1] = @$smts[0];
    @$systemsTrans[2] = @$smts[1];
    
    return $systemsTrans;
}


sub retrieve_RBtranslation {
    #description _ retrieve sentence RB translation paths
    #param1 _ sentence twig object
    
    my $SENTENCE = shift;
    my $verbose=0;
    my $max_alternatives_Node = 1;

    my @CHUNKS = $SENTENCE->children;
    my $chunk =  new Matxin::Chunk($CHUNKS[0], $verbose);
    my $chunk0_RBpath = $chunk->retrieve_RBpath();
    
    return ($chunk0_RBpath);
}

sub retrieve_SMTtranslation {
    #description _ retrieve sentence SMT translation (whole segment)
    #param1 _ segment twig object

    my $SEGMENT = shift;

    #my $translation = $SEGMENT->first_child->first_child->att('translation'); 
    my @translation = $SEGMENT->first_child->children('Alternative'); 
    my @smts;
    foreach my $child (@translation){
	if ($child->att('ord')==0 and $child->att('system') eq 'baseline'){
 	    $smts[0]=$child->att('translation');                                      # cris lm 
#  	    $smts[0]=$child->att('Analyzed');
        }elsif  ($child->att('ord')==0 and $child->att('system') eq 'generation'){
	    $smts[1]=$child->att('translation');
#  	    $smts[1]=$child->att('Analyzed');
        }
    }

    return (\@smts);
}

1;
