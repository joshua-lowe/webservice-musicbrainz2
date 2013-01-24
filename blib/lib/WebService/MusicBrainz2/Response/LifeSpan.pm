package WebService::MusicBrainz2::Response::LifeSpan;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Response::LifeSpan

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without and argument, they will return that state if it is available.

=head2 begin

=head2 end

=head2 ended

=cut

__PACKAGE__->mk_accessors(qw/begin end ended/);

=head1 AUTHOR

=over 4

=item Joshua Lowe  <joshua.lowe.dev@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Joshua Lowe

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
