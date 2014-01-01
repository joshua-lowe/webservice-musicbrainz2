#!/usr/bin/env perl -I ./lib
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/08/2013 10:17:40 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use WebService::MusicBrainz2::Response;
#my $inc = [qw/aliases recordings releases release-groups works tags ratings
#artist-credits discids media puids isrcs artist-rels label-rels
#recording-rels release-rels release-group-rels url-rels work-rels/];

my $inc = [qw/artist-credits labels discids recordings release-rels/];

#my $ws = WebService::MusicBrainz2->new_release;
#my $res = $ws->lookup('4088fa36-db46-4c62-9f3a-1f048262be37', $inc);
my $fh;
open($fh, "/rin/prj/hathor/XML/sire.xml");
my $xml = <$fh>;
close($fh);

my $res = WebService::MusicBrainz2::Response->new(XML => $xml);
print $res;
