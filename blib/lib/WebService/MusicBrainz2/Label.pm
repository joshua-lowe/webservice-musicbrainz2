package WebService::MusicBrainz2::Label;

use strict;
use WebService::MusicBrainz2::Query;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Label

=head1 SYNOPSIS

	use WebService::MusicBrainz2::Label;

	my $ws = WebService::MusicBrainz2::Label->new;

	my $response = $ws->search({ NAME => 'warner music' });

	my $label = $response->label; # get first in list

	print $label->name, " ", $artist->type, "\n";

	# OUTPUT: Warner Music Australia Distributor

=head1 DESCRIPTION

This module is used to query an artist from the MusicBrainz2 web service.

=head1 METHODS

=head2 new

This method is the constructor and it will make a call for initialization.

my $ws = WebService::MusicBrainz2::Label->new;

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
		qw/alias begin code comment country end ended ipi label labelaccent
		sortname type tag query basic/
	);

	$q->set_browse_params(
		qw/release/
	);

	$q->set_inc_params(
		qw/releases discids media artist-credits aliases
		tags ratings user-tags user-ratings
		artist-rels label-rels recording-rels release-rels release-group-rels
		url-rels work-rels/
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

=head2 search()

This method will perform the search of the MusicBrainz2 database through their web service schema and return a
response object.

    my $ws = WebService::MusicBrainz2::Label->new();
    
    my $response = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
    my $response = $ws->search({ NAME => 'throwing muses' });
    my $response = $ws->search({ NAME => 'james', LIMIT => 5 });
    my $response = $ws->search({ NAME => 'beatles', OFFSET => 5 });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });

=cut

sub search {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->search('label', $params);    

	return $response;
}

=head2 lookup

=cut

sub lookup {
	my $self = shift;
	my $mbid = shift;
	my $incs = shift;

	my $response = $self->query->lookup('label', $mbid, $incs);

	return $response;
}

=head2 browse

=cut

sub browse {
	my $self = shift;
	my $params = shift;

	my $response = $self->query->browse('label', $params);

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
