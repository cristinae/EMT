package Matxin::Syn;

use Modern::Perl;
use Matxin::Common;

sub new {
    #description _ creates a new Matxin::Syn object (class constructor) out from a given syn twig element
    #              (which is a sequence of chunks)
    #param1 _ syn element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $SYN = shift;
    my $verbose = shift;

    my $syn = { lem => Matxin::Common::get_attribute_value($SYN, 'lem'),
                sense => Matxin::Common::get_attribute_value($SYN, 'sense'),
                pos => Matxin::Common::get_attribute_value($SYN, 'pos'),
                mi => Matxin::Common::get_attribute_value($SYN, 'mi'),
                suf => Matxin::Common::get_attribute_value($SYN, 'suf')
    };

    bless $syn, $class;

    return $syn;
}

sub lem {
    #description _ returns the syn lem (lem attribute)
    #param1  _ syn reference  (implicit)
    #@return _ lem value

    my $syn = shift;

    return $syn->{lem};
}

1;
