package Matxin::Sentence;

use Modern::Perl;
use XML::Twig;
use Data::Dumper;
use Matxin::Common;
use Matxin::Chunk;

sub new {
    #description _ creates a new Matxin::Sentence object (class constructor) out from a given XML file
    #param1 _ sentence element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $SENTENCE = shift;
    my $verbose = shift;

    my $sentence = { alloc => Matxin::Common::get_attribute_value($SENTENCE, 'alloc'),
                 ord => Matxin::Common::get_attribute_value($SENTENCE, 'ord'),
                 ref => Matxin::Common::get_attribute_value($SENTENCE, 'ref'),
                 chunks => {} };

    bless $sentence, $class;

    my @CHUNKS = $SENTENCE->children;
    foreach my $chunk (@CHUNKS) { $sentence->add_chunk($chunk, $verbose); }

    return $sentence;
}

sub add_chunk {
    #description _ pushes a new chunk into the sentence
    #param1 _ sentence reference  (implicit)
    #param2 _ chunk element
    #param3 _ verbosity

    my $sentence = shift;
    my $CHUNK = shift;
    my $verbose = shift;

    my $chunk = new Matxin::Chunk($CHUNK, $verbose);
    $sentence->{chunks}->{$chunk->ord()} = $chunk;
}

sub chunks {
    #description _ returns the list of chunks in the sentence (sorted by ord, ASC)
    #param1  _ sentence reference  (implicit)
    #@return _ chunk list ref

    my $sentence = shift;
        
    my @values;
    foreach my $ord (sort {$a <=> $b} keys %{$sentence->{chunks}}) { push(@values, $sentence->{chunks}->{$ord}); }

    return \@values; 
}

sub ord {
    #description _ returns the sentence order (ord attribute)
    #param1  _ sentence reference  (implicit)
    #@return _ ord value

    my $sentence = shift;

    return $sentence->{ord};
}

sub retrieve_paths {
    #description _ retrieve sentence translation paths
    #param1 _ sentence reference (implicit)
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    
    my $sentence = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;

    my @paths;
    foreach my $chunk (@{$sentence->chunks()}) {
       my $chunk_paths = $chunk->retrieve_paths($max_alternatives_Node, $max_alternatives_AltTrans);
       Matxin::Common::concatenate_paths(\@paths, $chunk_paths);
    }
    
    return (\@paths);
}


sub retrieve_translation_options {
    #description _ retrieve sentence translation options for the table
    #param1 _ sentence reference (implicit)
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    #param4 _ word counts (hash ref)
    
    my $sentence = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $word_counts = shift;

    my %options;
    my @source;
    my $source_locals;
    my $i=0;
    foreach my $chunk (@{$sentence->chunks()}) {
       my ($chunk_table, $chunk_source) = $chunk->retrieve_translation_options($max_alternatives_Node, $max_alternatives_AltTrans, $word_counts, $source_locals);
       @options{keys %{$chunk_table}} = values %{$chunk_table};
       push(@source, $chunk_source);
    }
    
    return (\%options, \@source);
}


1;
