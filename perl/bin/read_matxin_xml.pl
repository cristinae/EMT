#!/usr/bin/perl

# Authors     : Jesus Gimenez
# Date        : June 2010
# Description : Reads an XML file encoding the output of the matxin RBMT system (into-memory) and prints a dumping
#
# Usage: read_matxin_xml.pl <file.xml>

use Modern::Perl;
use Matxin::SegmentList;
use Data::Dumper;

sub get_out
{
   $0 =~ /\/([^\/]*$)/;
   print STDERR "\nUsage: ", $1, "  [options]  <xml_file>\n\n";
   exit;
}

# -- check number of argments
my $NARG = 1;
my $ARGLEN = scalar(@ARGV);
if ($ARGLEN < $NARG) { die get_out(); }
my $XML_file = shift(@ARGV);

my $matxin_segment_list = new Matxin::SegmentList($XML_file, 1);

print Dumper $matxin_segment_list;
