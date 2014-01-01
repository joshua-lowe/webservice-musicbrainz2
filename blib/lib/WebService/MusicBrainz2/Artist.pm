package WebService::MusicBrainz2::Artist;

use strict;
use WebService::MusicBrainz2::Query;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Artist

=head1 SYNOPSIS

	use WebService::MusicBrainz2::Artist;
	my $ws = WebService::MusicBrainz2::Artist->new;
	my $response = $ws->search({ ARTIST => 'DJ Krush' });
	my $artist = $response->artist; # get first in list
	print $artist->name . " a  " . $artist->gender .  " born " . $artist->life_span->begin . "\n";
	# OUTPUT: DJ Krush a Male born 1962-07-29

=head1 DESCRIPTION

This module is used to query an artist from the MusicBrainz version 2 web service.

=head1 METHODS

=head2 new

This method is the constructor and it will make a call for initialization.  This
method takes any of four (4) optional parameters to specify enable various connections settings.

=over 4

=item HOST 

=back

The specific mirror server to connect to.  Defaults to "musicbrainz.org"

=over 4

=item USER

=back

The username used for athentication against the server.  This allows user-tags and user-rating to be retrived from the web service.  
Requires the PASS paramiter as well.  Defaults to undef (no authentication).

=over 4

=item PASS

=back

The password used for athentication against the server.

=over 4

=item RELM

=back

The http authentication relm used for athentication against the server.  Only required if the mirror uses a different relm in its HTTP AUTH setup.  Defaults to HOST.

my $ws = WebService::MusicBrainz2::Artist->new({HOST => 'de.musicbrainz.org', USER => 'username', PASS => 'secret');

=cut

sub new {
   my $class = shift;
   my $self = {};

   bless $self, $class;

   $self->_init(@_);

   return $self;
}

sub _init {
	my $self = shift;

	my $q = WebService::MusicBrainz2::Query->new(@_);

	$q->set_search_params(
		qw/arid artist artistaccent alias begin comment country end ended
		gender ipi sortname tag type query basic/
	);

	$q->set_browse_params(
		qw/aliases tags recording release-group release work/
	);

	$q->set_inc_params(
		qw/aliases recordings releases release-groups works tags ratings
		artist-credits discids media puids isrcs artist-rels label-rels
		recording-rels release-rels release-group-rels url-rels work-rels/
	);

	$q->set_browse_inc_params(
		qw/aliases tags ratings artist-rels label-rels recording-rels
		release-rels release-group-rels url-rels work-rels/
	);

	$self->{_query} = $q;
}

=head2 query

This method returns the cached WebService::MusicBrainz2::Query object.

=cut

sub query { shift->{_query} }

=head2 search

This method will perform the search of the MusicBrainz2 database through their web service schema and return a
response object.

    my $ws = WebService::MusicBrainz2::Artist->new();
    
    my $response = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
    my $response = $ws->search({ NAME => 'throwing muses' });
    my $response = $ws->search({ NAME => 'james', LIMIT => 5 });
    my $response = $ws->search({ NAME => 'beatles', OFFSET => 5 });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });

Multiple INC params can be delimited by whitespace, commas, or + characters.

    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases url-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases,url-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases+url-rels' });

=head3 Find a single artist by MBID

my $mbid_response = $ws->search({ MBID => '4eca1aa0-c79f-481b-af8a-4a2d6c41aa5c' });

=head3 Find a artist(s) by name

my $name_response = $ws->search({ NAME => 'Pantera' });

=head3 Find a artist(s) by name and limit results

my $name_limit_response = $ws->search({ NAME => 'Elvis', LIMIT => 3 });

=head3 Find a artist(s) by name and offset

my $name_offset_response = $ws->search({ NAME => 'Elvis', OFFSET => 10 });

=head3 Find a artist by MBID and include aliases

my $mbid_aliases_response = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases' });

=head3 Find a artist by MBID and include release groups

my $mbid_release_groups_response = $ws->search({ MBID => '4dca4bb2-23ba-4103-97e6-5810311db33a', INC => 'release-groups sa-Album' });

=head3 Find a artist by MBID and include artist relations

my $mbid_artist_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'artist-rels' });

=head3 Find a artist by MBID and include label relations

my $mbid_label_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'label-rels+sa-Official' });

=head3 Find a artist by MBID and include release relations

my $mbid_release_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });

=head3 Find a artist by MBID and include track relations

my $mbid_track_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });

=head3 Find a artist by MBID and include URL relations

my $mbid_url_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'url-rels' });

=head3 Find a artist by MBID and include tags

my $mbid_tags_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'tags' });

=head3 Find a artist by MBID and include ratings

my $mbid_ratings_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'ratings' });

=head3 Find a artist by MBID and include counts

my $mbid_counts_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'counts+sa-Official' });

=head3 Find a artist by MBID and include release events

my $mbid_rel_events_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-events+sa-Official' });

=head3 Find a artist by MBID and include discs

my $mbid_discs_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'discs+sa-Official' });

=head3 Find a artist by MBID and include labels

my $mbid_labels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'labels+release-events+sa-Official' });

=head3 Find a artist by direct Lucene query

my $q1_response = $ws->search({ QUERY => 'begin:1990 AND type:group'});

=cut

sub search {
   my $self = shift;
   my $params = shift;

   my $response = $self->query->search('artist', $params);    

   return $response;
}

=head2 lookup

=cut

sub lookup {
	my $self = shift;
	my $mbid = shift;
	my $incs = shift;

	my $response = $self->query->lookup('artist', $mbid, $incs);

	return $response;
}

=head2 browse

=cut

sub browse {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->browse('artist', $params);

	return $response;
}

=head1 AUTHOR

=over 4

=item Joshua Lowe <joshua.lowe.dev@gmail.com>

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Joshua Lowe
Copyright 2006-2009 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
