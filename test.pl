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
use WebService::MusicBrainz2;

my $ws = WebService::MusicBrainz2->new_work;
my $res = $ws->browse(
	{artist => '38d16213-25ba-450d-8665-4e08548e62e3',
	inc => [qw/aliases tags ratings artist-rels label-rels recording-rels release-rels release-group-rels url-rels work-rels/]}
);
print $res->artist
