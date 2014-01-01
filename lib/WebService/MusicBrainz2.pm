package WebService::MusicBrainz2;

use strict;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2

=head1 SYNOPSIS

	use WebService::MusicBrainz2;

	my $artist_ws = WebService::MusicBrainz2->new_artist;
	my $recording_ws = WebService::MusicBrainz2->new_release;
	my $release_ws = WebService::MusicBrainz2->new_release;
	my $release_group_ws = WebService::MusicBrainz2->new_release;
	my $label_ws = WebService::MusicBrainz2->new_label;
	my $work_ws = WebService::MusicBrainz2->new_track;

=head1 DESCRIPTION

This module will act as a factory using static methods to return specific web service objects;

=head1 METHODS

=head2 new_artist

Return new instance of WebService::MusicBrainz2::Artist object.

=cut

sub new_artist {
	my $class = shift;

	require WebService::MusicBrainz2::Artist;
	return WebService::MusicBrainz2::Artist->new;
}

=head2 new_release

Return new instance of WebService::MusicBrainz2::Release object.

=cut 

sub new_release {
	my $class = shift;

	require WebService::MusicBrainz2::Release;
	return WebService::MusicBrainz2::Release->new;
}

=head2 new_release_group

Return new instance of WebService::MusicBrainz2::ReleaseGroup object.

=cut 

sub new_release_group {
	my $class = shift;

	require WebService::MusicBrainz2::ReleaseGroup;
	return WebService::MusicBrainz2::ReleaseGroup->new;
}

=head2 new_work

Return new instance of WebService::MusicBrainz2::Work object.

=cut 

sub new_work {
	my $class = shift;

	require WebService::MusicBrainz2::Work;
	return WebService::MusicBrainz2::Work->new;
}

=head2 new_label

Return new instance of WebService::MusicBrainz2::Label object.

=cut 

sub new_label {
	my $class = shift;

	require WebService::MusicBrainz2::Label;
	return WebService::MusicBrainz2::Label->new;
}

=head2 new_recording

Return new instance of WebService::MusicBrainz2::Recording object.

=cut 

sub new_recording {
	my $class = shift;

	require WebService::MusicBrainz2::Recording;
	return WebService::MusicBrainz2::Recording->new;
}

sub new_work {
	my $class = shift;

	require WebService::MusicBrainz2::Work;
	return WebService::MusicBrainz2::Work->new;
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

http://musicbrainz.org/doc/XML_Web_Service/Version_2
http://wiki.musicbrainz.org/Database

=cut

1;
