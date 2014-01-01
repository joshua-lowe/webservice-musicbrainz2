package WebService::MusicBrainz2::Response::Release;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Response::Release

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without and argument, they will return that state if it is available.

=head2 id

=head2 title

=head2 status

=head2 quality

=head2 disambiguation

=head2 date

=head2 country

=head2 barcode

=head2 asin

=head2 text_rep

=head2 cover_art_archive

=head2 artist_credit

=head2 release_group

=head2 label_info_list

=head2 medium_list

=head2 relation_list

=head2 relation_lists

=head2 packaging

=head2 tag_list

=head2 user_tag_list

=head2 rating

=head2 user_rating

=head2 score

=cut

__PACKAGE__->mk_accessors(
	qw/id title status quality disambiguation date country barcode asin
	packaging cover_art_archive
	text_rep artist_credit release_group label_info_list medium_list
	relation_list relation_lists
	tag_list user_tag_list rating user_rating score/
);

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
