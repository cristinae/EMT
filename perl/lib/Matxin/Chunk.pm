package Matxin::Chunk;

use Modern::Perl;
use XML::Twig;
use boolean ':all';
use Data::Dumper;
use Matxin::Common;
use Matxin::NodeList;
use Matxin::Translation;

sub new {
    #description _ creates a new Matxin::Chunk object (class constructor) out from a given chunk twig element
    #              (which consists of a node, FullAltTrans, LocalAltTrans and, optionally, a sequence of chunks)
    #param1 _ chunk element (twig node)
    #param2 _ verbosity

    my $class = shift;     #implicit parameter
    my $CHUNK = shift;
    my $verbose = shift;

    my $chunk = { alloc => Matxin::Common::get_attribute_value($CHUNK, 'alloc'),
                  cas => Matxin::Common::get_attribute_value($CHUNK, 'cas'),
                  casalloc => Matxin::Common::get_attribute_value($CHUNK, 'casalloc'),
                  casref => Matxin::Common::get_attribute_value($CHUNK, 'casref'),
                  headlem => Matxin::Common::get_attribute_value($CHUNK, 'headlem'),
                  headpos => Matxin::Common::get_attribute_value($CHUNK, 'headpos'),
                  headsem => Matxin::Common::get_attribute_value($CHUNK, 'headsem'),
                  length => Matxin::Common::get_attribute_value($CHUNK, 'length'),
                  mi => Matxin::Common::get_attribute_value($CHUNK, 'mi'),
                  objMi => Matxin::Common::get_attribute_value($CHUNK, 'objMi'),
                  ord => Matxin::Common::get_attribute_value($CHUNK, 'ord'),
                  prep => Matxin::Common::get_attribute_value($CHUNK, 'prep'),
                  ref => Matxin::Common::get_attribute_value($CHUNK, 'ref'),
                  rel => Matxin::Common::get_attribute_value($CHUNK, 'rel'),
                  relalloc => Matxin::Common::get_attribute_value($CHUNK, 'relalloc'),
                  relref => Matxin::Common::get_attribute_value($CHUNK, 'relref'),
                  si => Matxin::Common::get_attribute_value($CHUNK, 'si'),
                  subMi => Matxin::Common::get_attribute_value($CHUNK, 'subMi'),
                  trans => Matxin::Common::get_attribute_value($CHUNK, 'trans'),
                  type => Matxin::Common::get_attribute_value($CHUNK, 'type'),

                  chunks => {},
                  node_list => undef,
                  FullAltTrans => undef,
                  LocalAltTrans => undef
    };

    bless $chunk, $class;

    my @CONTENTS = $CHUNK->children;
    foreach my $content (@CONTENTS) {
       if ($content->gi() eq $Matxin::Common::CHUNK_LABEL) { $chunk->add_chunk($content, $verbose); }
       elsif ($content->gi() eq $Matxin::Common::NODE_LABEL) { $chunk->set_node($content, $verbose); }
       elsif ($content->gi() eq $Matxin::Common::FullAltTrans_LABEL) { $chunk->set_FullAltTrans($content, $verbose); }
       elsif ($content->gi() eq $Matxin::Common::LocalAltTrans_LABEL) { $chunk->set_LocalAltTrans($content, $verbose); }
    }

    return $chunk;
}

sub add_chunk {
    #description _ pushes a new chunk into the chunk
    #param1 _ chunk reference  (implicit)
    #param2 _ chunk element
    #param3 _ verbosity

    my $chunk = shift;
    my $CHUNK = shift;
    my $verbose = shift;

    my $subchunk = new Matxin::Chunk($CHUNK, $verbose);
    $chunk->{chunks}->{$subchunk->ord()} = $subchunk;
}

sub ord {
    #description _ returns the chunk order (ord attribute)
    #param1  _ chunk reference  (implicit)
    #@return _ ord value

    my $chunk = shift;

    return $chunk->{ord};
}

sub headlem {
    #description _ returns the headlem (headlem attribute)
    #param1  _ chunk reference  (implicit)
    #@return _ headlem value

    my $chunk = shift;

    return $chunk->{headlem};
}

sub set_node {
    #description _ stores the node in the chunk (overwrites previous value)
    #param1 _ chunk reference  (implicit)
    #param2 _ node element
    #param3 _ verbosity

    my $chunk = shift;
    my $NODE = shift;
    my $verbose = shift;

    $chunk->{node_list} = new Matxin::NodeList($NODE, $verbose);
}

sub set_FullAltTrans {
    #description _ stores the FullAltTrans in the chunk (overwrites previous value)
    #param1 _ chunk reference  (implicit)
    #param2 _ FullAltTrans element
    #param3 _ verbosity

    my $chunk = shift;
    my $TRANS = shift;
    my $verbose = shift;

    $chunk->{FullAltTrans} = new Matxin::Translation($TRANS, $verbose);
}

sub get_FullAltTrans_string_list {
    #description _ retrieves the FullAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ FullAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;    

    return $chunk->{FullAltTrans}->alternatives($max_alternatives);
}

sub get_FullAltTransSyst_string_list {
    #description _ retrieves the FullAltTrans string list for a system in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve the alternatives from
    #@return _ FullAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;
    my $system = shift;    

    return $chunk->{FullAltTrans}->alternatives_systems($max_alternatives,$system);
}

sub get_FullAltTransFEATsSyst_string_list {
    #description _ retrieves the IBM scores for FullAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ FullAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;    
    my $system = shift;    

    return $chunk->{FullAltTrans}->features_systems($max_alternatives,$system);
}

sub get_FullAltTransAligns_string_list {
    #description _ retrieves the FullAltTransAlign string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ FullAltTransAlign list ref

    my $chunk = shift;
    my $max_alternatives = shift;    

    return $chunk->{FullAltTrans}->alignments($max_alternatives);
}

sub set_LocalAltTrans {
    #description _ stores the LocalAltTrans in the chunk (overwrites previous value)
    #param1 _ chunk reference  (implicit)
    #param2 _ LocalAltTrans element
    #param3 _ verbosity

    my $chunk = shift;
    my $TRANS = shift;
    my $verbose = shift;

    $chunk->{LocalAltTrans} = new Matxin::Translation($TRANS, $verbose);
}

sub get_LocalAltTrans_string_list {
    #description _ retrieves the LocalAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ LocalAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;    

    return $chunk->{LocalAltTrans}->alternatives($max_alternatives);
}

sub get_LocalAltTransSyst_string_list {
    #description _ retrieves the LocalAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #param3  _ system to retrieve the alternatives from
    #@return _ LocalAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;    
    my $system = shift;    

    return $chunk->{LocalAltTrans}->alternatives_systems($max_alternatives,$system);
}

sub get_LocalAltTransFEATsSyst_string_list {
    #description _ retrieves the IBM scores for LocalAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ LocalAltTrans list ref

    my $chunk = shift;
    my $max_alternatives = shift;    
    my $system = shift;    

    return $chunk->{LocalAltTrans}->features_systems($max_alternatives,$system);
}

sub get_LocalAltTransAligns_string_list {
    #description _ retrieves the LocalAltTransAligns string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ LocalAltTransAligns list ref

    my $chunk = shift;
    my $max_alternatives = shift;    

    return $chunk->{LocalAltTrans}->alignments($max_alternatives);
}

sub get_LocalAltTrans {
    #description _ retrieves the LocalAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #@return _ LocalAltTrans list ref

    my $chunk = shift;

    return $chunk->{LocalAltTrans};
}


sub get_FullAltTrans {
    #description _ retrieves the FullAltTrans string list in the chunk
    #param1  _ chunk reference  (implicit)
    #@return _ FullAltTrans list ref

    my $chunk = shift;

    return $chunk->{FullAltTrans};
}


sub get_NodeForm_string_list {
    #description _ retrieves the NodeForm string list in the chunk
    #param1  _ chunk reference  (implicit)
    #param2  _ maximum number of translation alternatives 
    #@return _ NodeForm list ref

    my $chunk = shift;
    my $max_alternatives = shift;    

    my @translations;
    if (defined($chunk->{node_list})) { @translations = @{$chunk->{node_list}->translations($max_alternatives)}; }
    return \@translations;
}

sub has_any_chunk_children {
    #description _ returns True if chunk has any chunk children, False otherwise
    #param1  _ chunk reference  (implicit)
    #@return _ True iff chunk has any chunk children, False otherwise

    my $chunk = shift;

    return (scalar(@{$chunk->chunks()}) != 0);
}


sub chunks {
    #description _ returns the list of subchunks in the chunk (sorted according to their "ord" value)
    #param1  _ chunk reference  (implicit)
    #@return _ chunk list ref

    my $chunk = shift;
    
    my @values;
    foreach my $ord (sort {$a <=> $b} keys %{$chunk->{chunks}}) { push(@values, $chunk->{chunks}->{$ord}); }
    
    return \@values; 
}


sub retrieve_paths {
    #description _ retrieve chunk translation paths
    #param1 _ chunk reference (implicit)
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    
    my $chunk = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;

    my @paths;
    
    #print "CHUNK [", $chunk->ord(), "]\n";
    
    if ($chunk->has_any_chunk_children()) { # non-terminal chunk
       #push local alternative combinations
       my $local_alt_list = $chunk->get_LocalAltTrans_string_list($max_alternatives_AltTrans);
       my $node_form_list = $chunk->get_NodeForm_string_list($max_alternatives_Node);
	#for keeping track of the system
       for my $t (@{$local_alt_list}) { $t .= $Matxin::Common::SMT_LABEL;}
       for my $t (@{$node_form_list}) { $t .= $Matxin::Common::RBMT_LABEL;}

       my $chunk_subpaths = [@{$local_alt_list}, @{$node_form_list}];
 
       my $ord = $chunk->ord();
       my $chunk_inserted = false;
       foreach my $subchunk (@{$chunk->chunks()}) {
          if (($subchunk->ord() > $ord) and !$chunk_inserted) { #concatenate chunk paths
            Matxin::Common::concatenate_paths(\@paths, $chunk_subpaths);
            $chunk_inserted = true;       	 
          }       	  
          #concatenate subchunk paths
          my $subpaths = $subchunk->retrieve_paths($max_alternatives_Node, $max_alternatives_AltTrans);
          Matxin::Common::concatenate_paths(\@paths, $subpaths);
       }
       
       if (!$chunk_inserted) { # concatenate chunk paths
          Matxin::Common::concatenate_paths(\@paths, $chunk_subpaths);
       }       	  
       
       #push full alternative(s)
       foreach my $t (@{$chunk->get_FullAltTrans_string_list($max_alternatives_AltTrans)}) {
	  $t .= $Matxin::Common::SMT_LABEL;
       	  push(@paths, $t);
       }       
    }
    else { # terminal chunk
       my $local_alt_list = $chunk->get_LocalAltTrans_string_list($max_alternatives_AltTrans);
       my $node_form_list = $chunk->get_NodeForm_string_list($max_alternatives_Node);
       for my $elem (@{$local_alt_list}) { $elem .= $Matxin::Common::SMT_LABEL;}
       for my $elem (@{$node_form_list}) { $elem .= $Matxin::Common::RBMT_LABEL;}
       @paths = (@{$local_alt_list}, @{$node_form_list});
    }

    #print Dumper (\@paths);
    
    return (\@paths);
}


sub retrieve_RBpath {
    #description _ retrieve RB chunk translation paths
    #param1 _ chunk reference (implicit)
    
    my $chunk = shift;

    my $max_alternatives_Node = 1;
    my $path='';
      
    if ($chunk->has_any_chunk_children()) { # non-terminal chunk

       my $node_form = $chunk->get_NodeForm_string_list($max_alternatives_Node);
 
       my $ord = $chunk->ord();
       my $chunk_inserted = false;
       foreach my $subchunk (@{$chunk->chunks()}) {
          if (($subchunk->ord() > $ord) and !$chunk_inserted) { #concatenate chunk paths
	    if ($path eq '') {$path=@$node_form[0];}
	     elsif (defined(@$node_form[0])) {$path = $path." ".@$node_form[0];} #pq hi ha traduccions buides
            $chunk_inserted = true;       	 
          }       	  
          #concatenate subchunk paths
          my $subpath = $subchunk->retrieve_RBpath();
	  if ($path eq '') {$path=$subpath;}
           else{$path = $path." ".$subpath;}
       }
       
       if (!$chunk_inserted) { # concatenate chunk paths
	    if ($path eq '') {$path=@$node_form[0];}
 	      elsif (defined(@$node_form[0])) {$path = $path." ".@$node_form[0];}
       }       	  
       
    }
    else { # terminal chunk
       my $node_form = $chunk->get_NodeForm_string_list($max_alternatives_Node);
       if ($path eq '') {$path=@$node_form[0];}
         else {$path = $path." ".@$node_form[0];}
    }

    return ($path);
}


sub retrieve_translation_options {
    #description _ retrieve chunk translation options
    #param1 _ chunk reference (implicit)
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    #param4 _ word counts (hash ref)
    
    my $chunk = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $word_counts = shift;
    my $source_locals = shift;

    my %table;
    my $source;
 
    if ($chunk->has_any_chunk_children()) { # non-terminal chunk

       #get alternative and node translations and IBM scores lists
#       my $local_alt_list = $chunk->get_LocalAltTrans_string_list($max_alternatives_AltTrans);
#       my $node_form_list = $chunk->get_NodeForm_string_list($max_alternatives_Node);
#       my $full_alt_list = $chunk->get_FullAltTrans_string_list($max_alternatives_AltTrans);
       my $local_alt_list_base = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $local_alt_list_gen  = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);    	
       my @local_alt_list = (@$local_alt_list_base,@$local_alt_list_gen);
       my $local_alt_list_RBMT = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);

       my $local_FEATs_list_base = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $local_FEATs_list_gen  = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
       my @local_FEATs_list = (@$local_FEATs_list_base,@$local_FEATs_list_gen);
       my $local_FEATs_list_RBMT = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);

       my $full_alt_list_base = $chunk->get_FullAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $full_alt_list_gen  = $chunk->get_FullAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
       my @full_alt_list = (@$full_alt_list_base,@$full_alt_list_gen);
       my $full_alt_list_RBMT = $chunk->get_FullAltTransSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);
       my $full_FEATs_list_base = $chunk->get_FullAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $full_FEATs_list_gen  = $chunk->get_FullAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
       my @full_FEATs_list = (@$full_FEATs_list_base,@$full_FEATs_list_gen);
       my $full_FEATs_list_RBMT = $chunk->get_FullAltTransFEATsSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);


       #get and index source
       my $source_full0 = $chunk->get_FullAltTrans()->get_source();
       my $source_local0 = $chunk->get_LocalAltTrans()->get_source();
       my $source_local = Matxin::Common::index_string($word_counts, $source_local0);
       push(@{$source_locals},$source_local);

       my $ord = $chunk->ord();
       my $chunk_inserted = false;
       my @full_source;

       foreach my $subchunk (@{$chunk->chunks()}) {
          if (($subchunk->ord() > $ord) and !$chunk_inserted) { #insert chunk here now
             push(@full_source, $source_local);
             $chunk_inserted = true;       	 
          }       	  

          #concatenate subchunk table	
          my ($subtable, $subsource) = $subchunk->retrieve_translation_options($max_alternatives_Node, $max_alternatives_AltTrans, $word_counts, $source_locals);

	  #%table = (%table, %{$subtable}); #aixo no anava be
          foreach my $source_phrase (keys %{$subtable}) {
             foreach my $target_phrase (keys %{$subtable->{$source_phrase}}) {
                $table{$source_phrase}->{$target_phrase} = $subtable->{$source_phrase}->{$target_phrase};
             }
          }
          push(@full_source, $subsource);
	 # }

       }#fi subchunk

       if (!$chunk_inserted) { # concatenate chunk table
          push(@full_source, $source_local);
       }       	  

       $source = join(" ", @full_source);

# Version 1.0: simple XML without multiple SMT systems
#       my $full_alt_aligns_list = $chunk->get_FullAltTransAligns_string_list($max_alternatives_AltTrans);
#       my $extra_local_alt_list;
#       my @multiple_locals;
#       if ($main::cd) {
#            foreach my $local (@{$source_locals}) {
#	       my $temp_list = locateLocalOnFulls($source_full0, $local, $full_alt_list, $full_alt_aligns_list, $max_alternatives_AltTrans);
#               push(@{$extra_local_alt_list},@{$temp_list});
#	       foreach my $tmp (@{$temp_list}) {
#		  push(@multiple_locals,$local);
#	       }
#            }
#       }
#       #push local extracted from full alternative(s)
#       if ($main::cd) {
#           Matxin::Common::append_phrase_multiplepairs(\%table, \@multiple_locals, $extra_local_alt_list, $Matxin::Common::CD_LABEL, $Matxin::Common::e);
#       }	

       #push full alternative(s)
       Matxin::Common::append_phrase_pairs(\%table, $source, \@full_alt_list, $Matxin::Common::SMT_LABEL, \@full_FEATs_list);
       #push local alternative(s)
       Matxin::Common::append_phrase_pairs(\%table, $source_local, \@local_alt_list, $Matxin::Common::SMT_LABEL, \@local_FEATs_list);
       if ($max_alternatives_Node) {
       	   Matxin::Common::append_phrase_pairs(\%table, $source_local, $local_alt_list_RBMT, $Matxin::Common::RBMT_LABEL, $local_FEATs_list_RBMT);
       	   Matxin::Common::append_phrase_pairs(\%table, $source, $full_alt_list_RBMT, $Matxin::Common::RBMT_LABEL, $full_FEATs_list_RBMT);
       }
       #push local extracted from full alternative(s)
       if ($main::cd) {
       	   my $local_alt_list_CDbase = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $local_alt_list_CDgen  = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @local_alt_list_CD = (@$local_alt_list_CDbase,@$local_alt_list_CDgen);
           my $local_FEATs_list_CDbase = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $local_FEATs_list_CDgen  = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @local_FEATs_list_CD = (@$local_FEATs_list_CDbase,@$local_FEATs_list_CDgen);
           my $full_alt_list_CDbase = $chunk->get_FullAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $full_alt_list_CDgen  = $chunk->get_FullAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @full_alt_list_CD = (@$full_alt_list_CDbase,@$full_alt_list_CDgen);
           my $full_FEATs_list_CDbase = $chunk->get_FullAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $full_FEATs_list_CDgen  = $chunk->get_FullAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @full_FEATs_list_CD = (@$full_FEATs_list_CDbase,@$full_FEATs_list_CDgen);
	   Matxin::Common::append_phrase_pairs(\%table, $source, \@full_alt_list_CD, $Matxin::Common::CD_LABEL, \@full_FEATs_list_CD);
	   Matxin::Common::append_phrase_pairs(\%table, $source_local, \@local_alt_list_CD, $Matxin::Common::CD_LABEL, \@local_FEATs_list_CD);
       }	

    }else { # terminal chunk
       my $local_alt_list_base = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $local_alt_list_gen  = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
       my @local_alt_list = (@$local_alt_list_base,@$local_alt_list_gen);
       my $local_FEATs_list_base = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
       my $local_FEATs_list_gen  = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
       my @local_FEATs_list = (@$local_FEATs_list_base,@$local_FEATs_list_gen);

       $source = $chunk->get_LocalAltTrans()->get_source();   
       $source = Matxin::Common::index_string($word_counts, $source);
       push(@{$source_locals},$source);

       Matxin::Common::append_phrase_pairs(\%table, $source, \@local_alt_list, $Matxin::Common::SMT_LABEL, \@local_FEATs_list);

       if ($max_alternatives_Node) {
           my $local_alt_list_RBMT = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);
           my $local_FEATs_list_RBMT = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);
       	   Matxin::Common::append_phrase_pairs(\%table, $source, $local_alt_list_RBMT, $Matxin::Common::RBMT_LABEL, $local_FEATs_list_RBMT);
       }
       if ($main::cd) {
       	   my $local_alt_list_CDbase = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $local_alt_list_CDgen  = $chunk->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @local_alt_list_CD = (@$local_alt_list_CDbase,@$local_alt_list_CDgen);
           my $local_FEATs_list_CDbase = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDbaseline);
           my $local_FEATs_list_CDgen  = $chunk->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::CDgeneration);
           my @local_FEATs_list_CD = (@$local_FEATs_list_CDbase,@$local_FEATs_list_CDgen);
	   Matxin::Common::append_phrase_pairs(\%table, $source, \@local_alt_list_CD, $Matxin::Common::CD_LABEL, \@local_FEATs_list_CD);
       }	

    }

   return (\%table, $source);
}




sub locateLocalOnFulls {
    #description _ retrieves the framents of fullAltTrans corresponding to the localAltTrans
    #param1 _ full source
    #param2 _ local source
    #param3 _ reference to the list with fullAltTrans
    #param4 _ reference to the list with the alignments fullAltTrans
    #param5 _ number of alternatives per translation (AltTrans elements) 
    #returns _ reference to a list with the new local translations, extracted from the full ones

    my $source_full = shift;
    my $source_local = shift;
    my $full_alt_list = shift;
    my $full_alt_aligns_list = shift;
    my $max_alternatives_AltTrans = shift; 

    my @extra_list;

    $source_full = ' '.$source_full.' ';
    $source_local =~ s/_\d+//g;
    if ($source_full =~ / \Q$source_local\E /) {

	my @words_source_local = split(/\s+/, $source_local);
	my @words_source_full = split(/\s+/, $source_full);
	shift @words_source_full; #pq he afegit l'espai en blanc
 	my ($ini, $end) = Matxin::Common::position_subarray(\@words_source_local,\@words_source_full); #situem el local dintre del full
	
	my $i=0;
        foreach my $fullAltAlign (@{$full_alt_aligns_list}) {
           my @match;
	   $fullAltAlign = ' '.$fullAltAlign;
	   for(my $j=$ini;$j<=$end;$j++){
		$_=$fullAltAlign;
	        my @tmp = /\s$j-(\d+)/g;
		push(@match,@tmp);
  	   }
#           print Dumper \@match;
           my @temp; my %vist;  #elimina duplicats
           foreach my $num (@match) {
    		push (@temp, $num) if not $vist{$num}++;
	   }
	   @match = sort {$a <=> $b}(@temp); #i ordena
	
	   my $fullAltTrans = @{$full_alt_list}[$i];
	   my @words = split(/\s+/, $fullAltTrans);
	   my $newTrans='';
	   for(my $j=0;$j<scalar(@match);$j++){
		$newTrans = $newTrans.$words[$match[$j]].' ';
  	   }           
	   chop($newTrans);
	   if ($newTrans ne '') {push(@extra_list,$newTrans)};  #si s'alinea a res es descarta
	   #push(@extra_list,$newTrans);
	   $i++;

	}


    }else{
# 	Com que es guarden tots els locals n'hi ha que no correspondran a aquest full
#	print "Local source should have matched Full source:\n  Full:$source_full\n  Local:$source_local\n\n";
    }

    return \@extra_list;
}


1;
