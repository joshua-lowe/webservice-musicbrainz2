package WebService::MusicBrainz2::Work;

use strict;
use WebService::MusicBrainz2::Query;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Works

=head1 SYNOPSIS

	use WebService::MusicBrainz2::Work;
    
	my $ws = WebService::MusicBrainz2::Work->new;
    
	my $response = $ws->search({ TITLE => 'Same in any language' });

	my $track = $response->track; # grab the first one from list

	print $track->title, " - ", $track->artist->name, "\n";

    # OUTPUT: Same In Any Language - I Nine

=head1 DESCRIPTION

This module is used to search the MusicBrainz2 database about track information.

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
	   qw/alias arid artist comment iswc lang tag type wid work workaccent query basic/
   );

   $q->set_browse_params(qw/artist/);

   $q->set_inc_params(
		qw/aliases tags ratings user-tags user-ratings artist-rels label-rels
		recording-rels release-rels release-group-rels url-rels work-rels/
   );

   $q->set_browse_inc_params(
	   qw/aliases tags ratings user-tags user-ratings artist-rels label-rels
	   recording-rels release-rels release-group-rels url-rels work-rels/
   );

   $self->{_query} = $q;
}

=head2 query

This method will return the cached WebService::MusicBrainz2::Query object.

=cut

sub query { shift->{_query} }

=head2 search

This method will search the MusicBrainz2 database about track related information.  The only argument is a hashref to
define the search parameters.

    my $ws = WebService::MusicBrainz2::Works->new;
    
    $ws->search({ TITLE => 'when the stars go blue' });
    $ws->search({ TITLE => 'blue', OFFSET => 100 });
    $ws->search({ ARTIST => 'Ryan Adams', TITLE => 'when the stars go blue' });
    $ws->search({ RELEASE => 'Gold', TITLE => 'when the stars go blue' });
    $ws->search({ DURATION => 200000, TITLE => 'when the stars go blue' });
    $ws->search({ TRACKNUM => 7, TITLE => 'when the stars go blue' });
    $ws->search({ ARTISTID => 'c80f38a6-9980-485d-997c-5c1a9cbd0d64', TITLE => 'when the stars go blue' });
    $ws->search({ RELEASEID => '433adbc2-382f-4f3a-9ce9-401f221f5b3b', TITLE => 'when the stars go blue' });
    $ws->search({ LIMIT => 5, TITLE => 'when the stars go blue' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'releases' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'puids' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist-rels' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'release-rels' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'track-rels' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'url-rels' });

Multiple INC params can be delimited by whitespace, commas, or + characters.

    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist url-rels' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist,url-rels' });
    $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist+url-rels' });

=cut

sub search {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->search('work', $params);    

	return $response;
}

=head2 lookup

=cut

sub lookup {
	my $self = shift;
	my $mbid = shift;
	my $incs = shift;

	my $response = $self->query->lookup('work', $mbid, $incs);

	return $response;
}

=head2 browse

=cut

sub browse {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->browse('work', $params);

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
