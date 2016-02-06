package Matxin::HybridTable;

#use Modern::Perl; PQ? cris
use Data::Dumper;
use IO::File;
use Matxin::Common;

sub new {
    #description _ creates a new Matxin::HybridTable object (class constructor) out from a given Matxin::Segment object
    #param1 _ segment
    #param2 _ number of alternatives per translation (Node) 
    #param3 _ number of alternatives per translation (AltTrans elements) 
    #param4 _ word counts (hash ref)
    #param5 _ verbosity

    my $class = shift;     #implicit parameter
    my $segment = shift;
    my $max_alternatives_Node = shift;
    my $max_alternatives_AltTrans = shift;
    my $word_counts = shift;
    my $verbose = shift;

    my $htable = { 'table' => {}, 'source' => ''};
    
    bless $htable, $class;

    foreach my $sentence (@{$segment->sentences()}) {
       my ($sentence_options, $sentence_source) = $sentence->retrieve_translation_options($max_alternatives_Node, $max_alternatives_AltTrans, $word_counts);

       foreach my $option (keys %{$sentence_options}) {
          $htable->{'table'}->{$option} = $sentence_options->{$option};
       }
       $htable->{'source'} = $htable->{'source'}.join(" ", @{$sentence_source}).' '; # he tret el .' '. del mig i l'he posat al final
    }
    if ($htable->{'source'} =~ /(.*)\s+$/){$htable->{'source'} = $1;}

    #print Dumper $htable->{'source'};
    #push full alternative(s)
    my $src = $htable->{'source'}; 

    my $local_FEATs_list_base = $segment->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline);
    my @feats = @$local_FEATs_list_base;
    my $i=0;
    foreach my $t (@{$segment->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::baseline)}) { 
	$t = $t.' '.$Matxin::Common::SMT_LABEL;
        $htable->{'table'}->{$src}->{$t} = $feats[$i].' x';
        $i++;
    }  
    my $local_FEATs_list_gen = $segment->get_LocalAltTransFEATsSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation);
    @feats = @$local_FEATs_list_gen;
    $i=0;
    foreach my $t (@{$segment->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::generation)}) { 
	$t = $t.' '.$Matxin::Common::SMT_LABEL;
        $htable->{'table'}->{$src}->{$t} = $feats[$i].' x';
        $i++;
    }  
    if ($max_alternatives_Node) {
       my $local_FEATs_list_RBMT = $segment->get_LocalAltTransFEATsSyst_string_list($max_alternatives_Node,$Matxin::Common::RBMT);
       @feats = @$local_FEATs_list_RBMT;
       $i=0;
       foreach my $t (@{$segment->get_LocalAltTransSyst_string_list($max_alternatives_AltTrans,$Matxin::Common::RBMT)}) { 
	   $t = $t.' '.$Matxin::Common::RBMT_LABEL;
           $htable->{'table'}->{$src}->{$t} = $feats[$i].' x';
           $i++;
       }  
    }

    return $htable;
}

sub print_file {
    #description _ prints all phrases onto a given file
    #param1 _ output filename

    my $htable = shift;     #implicit parameter    
    my $file = shift;
    my $fileT = shift;
    	
    my $out = new IO::File(">> $file");
    my $test = new IO::File(">> $fileT");

    my $sentence = lc($htable->{'source'});
    $sentence =~ s/^\s+//;
    print $test Matxin::Common::replace_xml_entities($sentence), "\n"; 
    foreach my $source (keys %{$htable->{'table'}}) { 

       $source=~s/^\s+//;
       $source=~s/\s+$//;
       my @paraules = split(/\s+/, $source);
       my $numParaules = @paraules;
	
       my @targets = keys %{$htable->{'table'}->{$source}};
       my @feats = values %{$htable->{'table'}->{$source}};
       my %targetPhrases;
       my $source_lc = lc($source);
       my $both;
       my $smt=0;
       my $rbmt=0;
       my $cd=0;
       my $smt_xs='';
       my $rbmt_xs='';
       my $cd_xs='';
       my $scores;
       my $i=0;
       foreach my $target (keys %{$htable->{'table'}->{$source}}) { 
 	  my $target_lc = lc($target);
          my ($text, $label) = split (/ \[/,$target_lc);

          $smt=0;
	  $rbmt=0;
	  $cd=0;
          $both=0;
          $smt_xs='';
          $rbmt_xs='';
          $cd_xs='';
	  my $j=0;
          foreach my $elem (@targets){
            $elem = lc($elem);
            my $cadena = $text.' '.$Matxin::Common::CD_LABEL;
            if ($elem =~/\Q$cadena\E/ ){
		$cd=1;
 		$feats[$j] =~ / (x+)$/;
		$cd_xs .= $1;
	    } 
	    $cadena = $text.' '.$Matxin::Common::SMT_LABEL;
            if ($elem =~/\Q$cadena\E/ ){
		$smt=1;
 		$feats[$j] =~ / (x+)$/;
		$smt_xs .= $1;
	    }
	    $cadena = $text.' '.$Matxin::Common::RBMT_LABEL;
            if ($elem =~/\Q$cadena\E/ ){
		$rbmt=1;
 		$feats[$j] =~ / (x+)$/;
		$rbmt_xs .= $1;
	    }
            $j++;
          }

          #  print "$source ||| $smt_xs $cd_xs $rbmt_xs ||| $smt $cd $rbmt $both\n";
          my $sistema = '';
	  if ($smt==1 && $cd==0 && $rbmt==0){$sistema = $Matxin::Common::SMT_LABEL;}
	   elsif($smt==0 && $cd==1 && $rbmt==0){$sistema = $Matxin::Common::CD_LABEL;}
	   elsif($smt==1 && $cd==1 && $rbmt==0){$sistema = $Matxin::Common::SMT_LABEL;}
	   elsif($smt==0 && $cd==0 && $rbmt==1){$sistema = $Matxin::Common::RBMT_LABEL;}
	   elsif(($smt==1||$cd==1) && $rbmt==1){$sistema = $Matxin::Common::BOTH_LABEL; $both=1;}

#cris debug          my $targetINI=$target;
          $target =~ s/\[\w{2,4}\]/$sistema/;

          $feats[$i] =~ /(.+) (x+)$/;   #ibms et al.
          $scores0 = $1.' '; 
          $scores = $1.' '; 
          my $xs = $smt_xs.$cd_xs.$rbmt_xs; #sistemes que favoreixen la phrase
          my $length_xs = length($xs);       
          my $valor = $length_xs;
          $scores .= $valor.' ';
	  if ($smt||$cd) {$scores .= $Matxin::Common::e.' ';}  #features binaris en el ln 
             else {$scores .= $Matxin::Common::one.' ';}
	  if ($rbmt) {$scores .= $Matxin::Common::e.' ';}
             else {$scores .= $Matxin::Common::one.' ';}
	  if ($both) {
               $valor = $Matxin::Common::e ** $numParaules;
               $scores .= $valor.' ';
          } else {$scores .= $Matxin::Common::one.' ';}
          $scores .= $Matxin::Common::e; #phrase penalty
          $scores0 .= $Matxin::Common::e; #phrase penalty

	  $targetPhrases{$target}=$scores;
#cris debug         print "\nTARGET $source ||| $targetINI $scores"; <STDIN>;
          $i++;
       } #fi target

       foreach my $elem (keys %targetPhrases){
        $elem_lc = lc($elem);

        my ($text, $label) = split (/ \[/,$elem_lc);

#        print $source_lc, " ||| ", $elem_lc, " ||| ", $targetPhrases{$elem}, "\n";
	my $sourceNOXML = Matxin::Common::replace_xml_entities($source_lc);
	my $elemNOXML = Matxin::Common::replace_xml_entities($elem_lc);
        my $targetElemNOXML = Matxin::Common::replace_xml_entities($targetPhrases{$elem});
	my $textNOXML = Matxin::Common::replace_xml_entities($text);
        if ($main::trace) {print $out $sourceNOXML, " ||| ", $elemNOXML, " ||| ", $targetElemNOXML, " ||| ", " ||| ", "\n";}
          else {print $out $sourceNOXML, " ||| ", $textNOXML, " ||| ", $targetElemNOXML, " ||| ", " ||| ", "\n";}

       }

    }
    $out->close(); 
    $out->close(); 
      
}


1;

