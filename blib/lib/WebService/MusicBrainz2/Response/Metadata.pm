package WebService::MusicBrainz2::Response::Metadata;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Response::Metadata

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without and argument, they will return that state if it is available.

=head2 generator

=head2 created

=head2 artist

=head2 artist_list

=head2 release

=head2 release_list

=head2 recording

=head2 recording_list

=head2 release_group

=head2 release_group_list

=head2 work

=head2 work_list

=head2 label

=head2 label_list

=head2 score

=cut

__PACKAGE__->mk_accessors(
	qw/generator created artist artist_list recording recording_list 
	release release_list release_group release_group_list work work_list
	label label_list score/
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
