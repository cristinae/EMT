package Matxin::Node;

use Modern::Perl;
use XML::Twig;
use Data::Dumper;
use Matxin::Common;
use Matxin::Syn;

sub new {
    #description _ creates a new Matxin::Node object (class constructor) out from a given node twig element
    #param1 _ node element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $NODE = shift;
    my $verbose = shift;

    my $node = { form => Matxin::Common::get_attribute_value($NODE, 'form'),
                 ref => Matxin::Common::get_attribute_value($NODE, 'ref'),
                 alloc => Matxin::Common::get_attribute_value($NODE, 'alloc'),
                 ord => Matxin::Common::get_attribute_value($NODE, 'ord'),
                 lem => Matxin::Common::get_attribute_value($NODE, 'lem'),
                 pos => Matxin::Common::get_attribute_value($NODE, 'pos'),
                 mi => Matxin::Common::get_attribute_value($NODE, 'mi'),

                 slem => Matxin::Common::get_attribute_value($NODE, 'slem'),
                 smi => Matxin::Common::get_attribute_value($NODE, 'smi'),
                 sense => Matxin::Common::get_attribute_value($NODE, 'sense'),
                 UpCase => Matxin::Common::get_attribute_value($NODE, 'UpCase'),

                 sem => Matxin::Common::get_attribute_value($NODE, 'sem'),
                 suf => Matxin::Common::get_attribute_value($NODE, 'suf'),
                 unknown => Matxin::Common::get_attribute_value($NODE, 'unknown'),

                 node => undef,
                 syns => []
    };

    bless $node, $class;

    my @CONTENTS = $NODE->children;
    foreach my $content(@CONTENTS) {
       if ($content->gi() eq $Matxin::Common::NODE_LABEL) { $node->set_node($content, $verbose); }
       elsif ($content->gi() eq $Matxin::Common::SYN_LABEL) { $node->add_syn($content, $verbose); }
    }

    return $node;
}

sub set_node {
    #description _ stores the node in the node (overwrites previous value)
    #param1 _ node reference  (implicit)
    #param2 _ node element
    #param3 _ verbosity

    my $node = shift;
    my $NODE = shift;
    my $verbose = shift;

    $node->{node} = new Matxin::Node($NODE, $verbose);
}

sub translations {
    #description _ returns the translations of the node
    #param1  _ node reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ translations (list ref)

    my $node = shift;
    my $max_alternatives = shift;    
	
    my @translations;
    if ($max_alternatives > 0) {
       my $form=$node->{form};
#       $form=lc($form); #cris
       push(@translations, $form);
       my $i = 0;
       $max_alternatives--;
       while (($i < scalar(@{$node->{syns}})) and ($i < $max_alternatives)) {
          push(@translations, $node->{syns}->[$i]->lem());
          $i++;
       }
    }

    return \@translations;
}

sub add_syn {
    #description _ pushes a new syn into the node
    #param1 _ node reference  (implicit)
    #param2 _ syn element
    #param3 _ verbosity

    my $node = shift;
    my $SYN = shift;
    my $verbose = shift;

    push(@{$node->{syns}}, new Matxin::Syn($SYN, $verbose));
}

sub ord {
    #description _ returns the node order (ord attribute)
    #param1  _ node reference  (implicit)
    #@return _ ord value

    my $node = shift;

    return $node->{ord};
}

1;
