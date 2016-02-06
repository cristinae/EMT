package Matxin::NodeList;

use Modern::Perl;
use Matxin::Common;
use Matxin::Node;
use Data::Dumper;

sub new {
    #description _ creates a new Matxin::NodeList object (class constructor) out from a given 1st node element
    #param1 _ node element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $NODE = shift;
    my $verbose = shift;

    my $node_list = { };
    bless $node_list, $class;

    $node_list->add($NODE, $verbose);

    return $node_list;
}

sub add {
    #description _ pushes a new node into the node list
    #param1 _ node list reference  (implicit)
    #param2 _ node element
    #param3 _ verbosity

    my $node_list = shift;
    my $NODE = shift;
    my $verbose = shift;

    my $node = new Matxin::Node($NODE, $verbose);
    $node_list->{$node->ord()} = $node;

    my @CONTENTS = $NODE->children;
    foreach my $content (@CONTENTS) {
       if ($content->gi() eq $Matxin::Common::NODE_LABEL) { $node_list->add($content, $verbose); }
    }
}

sub nodes {
    #description _ returns the list of nodes in the list (sorted according to their "ord" value)
    #param1  _ node_list reference  (implicit)
    #@return _ node list ref

    my $node_list = shift;
    
    my @values;
    foreach my $ord (sort {$a <=> $b} keys %{$node_list}) { push(@values, $node_list->{$ord}); }
    
    return \@values; 
}

sub translations {
    #description _ returns the translations of a given node list (considering up to a given maximum number of transations per node)
    #param1  _ node list reference  (implicit)
    #param2  _ maximum number of translation alternatives per node

    my $node_list = shift;
    my $max_alternatives = shift;    

    my @translations;
    foreach my $node (@{$node_list->nodes()}) {
       my $node_translations = $node->translations($max_alternatives);
       Matxin::Common::concatenate_paths(\@translations, $node_translations);
    }

    return \@translations;
}

1;
