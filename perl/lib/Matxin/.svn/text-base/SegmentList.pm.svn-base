package Matxin::SegmentList;

use Modern::Perl;
use XML::Twig;
use Matxin::Common;
use Matxin::Segment;

sub new {
    #description _ creates a new Matxin::SegmentList object (class constructor) out from a given XML file
    #param1 _ XML file
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $xml = shift;
    my $verbose = shift;

    my $segment_list = [ ];
    bless $segment_list, $class;

    my $twig = XML::Twig->new( keep_encoding => 1 );
    if (-e $xml) { $twig->parsefile($xml); }
    else { die "[ERROR] could not find XML file <$xml>\n"; }

    my $CORPUS = $twig->root;
    $segment_list->process_corpus($CORPUS, $verbose);

    return $segment_list;
}

sub process_corpus {
    #description _ process a corpus element (which is a sequence of sentences)
    #param1 _ segment list reference  (implicit)
    #param2 _ corpus element
    #param3 _ verbosity

    my $segment_list = shift;
    my $CORPUS = shift;
    my $verbose = shift;

    my @SEGMENTS = sort { Matxin::Common::get_attribute_value($a, 'ord') <=> Matxin::Common::get_attribute_value($a, 'ord') } $CORPUS->children;
    foreach my $segment (@SEGMENTS) { $segment_list->add($segment, $verbose); }
}

sub add {
    #description _ pushes a new segment into the segment list
    #param1 _ segment list reference  (implicit)
    #param2 _ segment element
    #param3 _ verbosity

    my $segment_list = shift;
    my $segment = shift;
    my $verbose = shift;

    push(@{$segment_list}, new Matxin::Segment($segment, $verbose));
}

1;
