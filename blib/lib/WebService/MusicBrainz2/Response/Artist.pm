package WebService::MusicBrainz2::Response::Artist;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Response::Artist

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without an argument, they will return that state if it is available.

=head2 id

=head2 type

=head2 name

=head2 sort_name

=head2 disambiguation

=head2 gender

=head2 country

=head2 life_span

=head2 alias_list

=head2 ipi

=head2 ipi_list

=head2 recording_list

=head2 release_list

=head2 release_group_list

=head2 work_list

=head2 relation_list

=head2 relation_lists

=head2 tag_list

=head2 user_tag_list

=head2 rating

=head2 user_rating

=head2 score

=cut

__PACKAGE__->mk_accessors(
	qw/id type name sort_name disambiguation life_span ipi ipi_list gender
	country alias_list recording_list release_list release_group_list work_list 
	relation_list relation_lists tag_list user_tag_list rating user_rating
	score/
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
