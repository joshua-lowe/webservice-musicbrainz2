package WebService::MusicBrainz2::Release;

use strict;
use WebService::MusicBrainz2::Query;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Release

=head1 SYNOPSIS

	use WebService::MusicBrainz2::Release;
    
	my $ws = WebService::MusicBrainz2::Release->new;
    
	my $response = $ws->search({ TITLE => 'ok computer' });

	my $release = $response->release; # grab first one in the list

	print $release->title, " (", $release->type, ") - ", $release->artist->name, "\n";

	# OUTPUT: OK Computer (Album Official) - Radiohead

=head1 DESCRIPTION

=head1 METHODS

=head2 new

This method is the constructor and it will call for  initialization.

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
		qw/query arid artist artistname asin barcode catno comment country
		creditname date discids discidsmedium format laid label lang mediums
		primarytype puid reid release releaseaccent rgid script secondarytype
		status tracks tracksmedium type query basic/
	);

	$q->set_browse_params(
		qw/artist label recording release-group/
	);

	$q->set_inc_params(
		qw/artists labels recordings release-groups discids media puids isrcs
		artist-credits aliases echoprints
		tags ratings user-tags user-ratings
		artist-rels label-rels recording-rels release-rels release-group-rels
		url-rels work-rels recording-level-rels work-level-rels annotation/
	);

	$q->set_browse_inc_params(
		qw/artist-credits labels recordings release-groups media discids
		artist-rels label-rels recording-rels release-rels release-group-rels
		url-rels work-rels/
	);

	$self->{_query} = $q;
}

=head2 query

This method will return the cached query object;

=cut

sub query { shift->{_query} }

=head2 search

This method is used to search the MusicBrainz2 database using their web service schema.  The only argument is a hashref
to define the search parameters.

    my $ws = WebService::MusicBrainz2::Release->new;
    
    my $response = $ws->search({ TITLE => 'Highway to Hell' });
    my $response = $ws->search({ ARTIST => 'sleater kinney' });
    my $response = $ws->search({ ARTIST => 'beatles', OFFSET => 4 });
    my $response = $ws->search({ ARTISTID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab' });
    my $response = $ws->search({ DISCID => 'XgrrQ8Npf9Uz_trPIFMrSz6Mk6Q-' });
    my $response = $ws->search({ RELEASETYPES => 'Official', MBID => 'a89e1d92-5381-4dab-ba51-733137d0e431' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'counts' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-events' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'discs' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'tracks' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'track-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'url-rels' });

Multiple INC params can be delimited by whitespace, commas, or + characters.

    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist url-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist,url-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist+url-rels' });

=head3 Find a release by title

my $rel_title = $ws->search({ TITLE => 'Van Halen' });

=head3 Find a release by disc id

my $rel_discid = $ws->search({ DISCID => 'Qb6ACLJhzNM46cXKVZSh3qMOv6A-' });

=head3 Find a release by artist name 

my $rel_artist_response = $ws->search({ ARTIST => 'Van Halen' });

=head3 Find a release by artist MBID

my $rel_artistid_response = $ws->search({ ARTISTID => 'b665b768-0d83-4363-950c-31ed39317c15' });

=head3 Find a release by artist name and release type

my $rel_reltypes_response = $ws->search({ ARTIST => 'Van Halen', RELEASETYPES => 'Bootleg' });

=head3 Find a release by artist name and count

my $rel_count_response = $ws->search({ ARTIST => 'Van Halen', COUNT => 10 });

=head3 Find a release by artist name and release date

my $rel_date_response = $ws->search({ ARTIST => 'Van Halen', DATE => '1980' });

=head3 Find a release by artist name and limit

my $rel_limit_response = $ws->search({ ARTIST => 'Van Halen', LIMIT => "40" });

=head3 Find a release by MBID and include counts

my $rel_mbid_counts_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'counts' });

=head3 Find a release by MBID and include release events

my $rel_mbid_events_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'release-events' });

=head3 Find a release by MBID and include discs

my $rel_mbid_discs_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'discs' });

=head3 Find a release by MBID and include tracks

my $rel_mbid_tracks_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'tracks' });

=head3 Find a release by MBID and include release groups

my $rel_mbid_relgroups_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'release-groups' });

=head3 Find a release by MBID and include artist relations

my $rel_mbid_artistrels_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'artist-rels' });
 
=head3 Find a release by MBID and include URL relations

my $rel_mbid_urlrels_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'url-rels' });

=head3 Find a release by MBID and include tags

my $rel_mbid_tags_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'tags' });

=head3 Find a release by MBID and include ratings

my $rel_mbid_ratings_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'ratings' });

=cut

sub search {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->search('release', $params);    

	return $response;
}


sub lookup {
	my $self = shift;
	my $mbid = shift;
	my $incs = shift;

	my $response = $self->query->lookup('release', $mbid, $incs);

	return $response;
}

sub browse {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->browse('release', $params);

	return $response;
}

=head1 AUTHOR

=over 4

=item Joshua Lowe <joshua.lowe.dev@gmail.com>
=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Joshua Lowe
Copyright 2006-2007 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
