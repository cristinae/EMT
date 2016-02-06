package Matxin::HybridPaths;

use Modern::Perl;
use Data::Dumper;
use IO::File;
use Matxin::Common;

sub new {
    #description _ creates a new Matxin::HybridPaths object (class constructor) out from a given Matxin::Segment object
    #param1 _ segment
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    #param4 _ verbosity

    my $class = shift;     #implicit parameter
    my $segment = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $verbose = shift;

    my $hpaths = [];
    
    bless $hpaths, $class;

    foreach my $sentence (@{$segment->sentences()}) {
       Matxin::Common::concatenate_paths($hpaths, $sentence->retrieve_paths($max_alternatives_Node, $max_alternatives_AltTrans));
    }

    #push full alternative(s)
    foreach my $t (@{$segment->get_LocalAltTrans_string_list($max_alternatives_AltTrans)}) { 
	$t .= $Matxin::Common::SMT_LABEL;
	push(@{$hpaths}, $t); 
    }
    
    return $hpaths;
}

sub print_file {
    #description _ prints all possible traverse paths onto a given file
    #param1 _ output filename

    my $hpaths = shift;     #implicit parameter    
    my $file = shift;
    	
    my $out = new IO::File("> $file");
    my $outclean = new IO::File("> $file.clean");
    foreach my $t (@{$hpaths}) { 
	print $out "$t\n";
        $t =~ s/\[SMT\]|\[RBMT\]//g; 
#        $t =~ s/\[RBMT\]//g; 
	print $outclean "$t\n"; 
    }
    $out->close();
    $outclean->close();
}

1;
