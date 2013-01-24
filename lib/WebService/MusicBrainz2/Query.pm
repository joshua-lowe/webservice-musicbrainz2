package WebService::MusicBrainz2::Query;

use strict;
use LWP::UserAgent;
use URI;
use URI::Escape;
use WebService::MusicBrainz2::Response;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Query

=head1 SYNOPSIS

=head1 ABSTRACT

WebService::MusicBrainz2 - Interface with the MusicBrainz version 2 web service.

=head1 DESCRIPTION

This module's relationship with WebService::MusicBrainz2::Artist, WebService::MusicBrainz2::ReleaseGroup, Webservice::MusicBrainz2::Label, WebService::MusicBrainz2::Recording, WebService::MusicBrainz2::Release, and WebService::MusicBrainz2::Work is a "has a" relationship.  This module will not be 
instantiated by any client but will only be used internally within the Artist, Release, Release Group, Work, Label or Recording classes.

=head1 METHODS

=head2 new

This method is the constructor and it will call for initialization.  It takes three optional parameters, HOST, USER, PASSWORD.
The HOST parameter can be passed to select a different mirrored server, USER and PASSWORD are authentication which is required to retrive some user specific tags/rattings.

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
	my %params = @_;

	my $web_service_uri = URI->new;

	my $web_service_uri_scheme = "http";
	my $web_service_host = $params{HOST} || 'musicbrainz.org';
	my $web_service_relm = $params{RELM} if $params{RELM};
	my $web_serivce_user = $params{USER} if $params{USER};
	my $web_serivce_pass = $params{PASS} if $params{PASS};
	my $web_service_namespace = 'ws';
	my $web_service_version = '2';

	$web_service_uri->scheme($web_service_uri_scheme);
	$web_service_uri->host($web_service_host);
	$web_service_uri->path("$web_service_namespace/$web_service_version/");

	$self->{_baseurl} = $web_service_uri->as_string;
}

=head2 set_url_params

Define a list of valid URL query parameters.

=cut

sub set_url_params {
	my $self = shift;
	my @params = @_;

	foreach my $p (@params) {
		push @{ $self->{_valid_url_params} }, lc($p);
	}
}

=head2 set_search_params

Define a list of valid URL query parameters.

=cut

sub set_search_params {
	my $self = shift;
	my @params = @_;

	foreach my $p (@params) {
		push @{ $self->{_valid_search_params} }, lc($p);
	}
}

=head2 set_inc_params

Define a list of valid arguments for the "inc" URL query parameter.

=cut

sub set_inc_params {
	my $self = shift;
	my @params = @_;

	foreach my $p (@params) {
		push @{ $self->{_valid_inc_params} }, lc($p);
	}
}

=head2 set_browse_params 

=cut

sub set_browse_params {
	my $self = shift;
	my @params = @_;

	for my $p (@params) {
		push  @{ $self->{_valid_browse_params} }, lc($p);
	}
}

=head2 set_browse_inc_params

=cut

sub set_browse_inc_params {
	my $self = shift;
	my @params = @_;

	for my $p (@params) {
		push @{ $self->{_valid_browse_inc_params} }, lc($p);
	}
}

=head2 _get

Perform the URL request (GET) and if success, then return a WebService::MusicBrainz2::Response object.  Otherwise die.

=cut

sub _get {
	my $self = shift;
	my $url = shift;

	my $ua = LWP::UserAgent->new;
	$ua->env_proxy;

	$ua->agent("WebService::MusicBrainz2/$VERSION");

	my $response = $ua->get($url);

	if($response->code eq "200") {
		my $r = WebService::MusicBrainz2::Response->new( XML => $response->content );

		return $r;
	}

	die "URL (", $url, ") Request Failed - Code: ", $response->code, " Error: ", $response->message, "\n";
}

=head2 lookup

Perform a lookup request to the version 2 MusicBrains service

=cut

sub lookup {
	my $self = shift;
	my $class = shift;
	my $mbid = shift;
	my $incs = shift;

	#my $url = $self->_url($class, $mbid, $incs);
	my $url =  $self->{_baseurl} . $class . '/' . $mbid ;

	my ($usable, $failed) = $self->_validate_incs($incs);

	$url .= "?inc=$usable" if $usable;

	return $self->_get($url);
}

sub _validate_incs {
	my $self = shift;
	my $incs = shift;
	my @use;
	my $fail = [];

	for my $inc (@$incs){
		if ($inc ~~ @{$self->{_valid_inc_params}}){
			push @use, $inc;
		} else {
			push @$fail, $inc;
		}
	}

	my $url = join '+', @use;
	return ($url, $fail);
}

sub search {
	my $self = shift;
	my $class = shift;
	my $params = shift;

	my $url = $self->{_baseurl} . $class . '?query=';

	my ($q, $bad) = $self->_validate_search_params($params);

	$url .= $q;

	return $self->_get($url);
}

sub _validate_search_params {
	my $self = shift;
	my $params = shift;

	return URI::Escape::uri_escape_utf8($params) if(!ref($params));

	my @terms;
	my $failed = [];
	my ($constraint, $query, $inc);

	for my $key (keys %$params){
		if(lc($key) ~~ @{$self->{_valid_search_params}}){
			my $sanitized = URI::Escape::uri_escape_utf8($$params{$key});
			push @terms, "$key:$sanitized";
		} else {
			push @$failed, $key;
		}

		$query = URI::Escape::uri_escape_utf8($$params{$key}) if($key =~ /^query$/);

		if ($key =~ /^limit$|^offset/i){
			next if $$params{$key} !~ /^\d+$/;
			$constraint .= "&" . lc($key) . "=$$params{$key}";
		}

		if(lc($key) eq 'inc'){
			($inc, undef) = $self->_validate_incs($$params{$key});
		}
	}

	my $url = join ' AND ', @terms;
	$url = $query if $query;
	$url .= "&inc=$inc" if $inc;
	$url .= $constraint if $constraint;

	return ($url, $failed);
}

sub browse {
	my $self = shift;
	my $class = shift;
	my $params = shift;

	my $url = $self->{_baseurl} . $class . '?';

	my ($r, undef) = $self->_validate_browse_params($params);

	$url .= $r;

	return $self->_get($url);
}

sub _validate_browse_params {
	my $self = shift;
	my $params = shift;
	my @use;
	my $fail = [];
	my ($inc, $constraint);

	for my $key (keys %$params) {
		if ($key ~~ @{$self->{_valid_browse_params}}){
			push @use, "$key=$$params{$key}";
		} else {
			push @$fail, $key;
		}

		if ($key =~ /^limit$|^offset/i){
			next if $$params{$key} !~ /^\d+$/;
			$constraint .= "&" . lc($key) . "=$$params{$key}";
		}

		if(lc($key) =~ /^inc$/) {
			($inc, undef) = $self->_validate_browse_incs($$params{$key});
		}
	}

	my $url = join '+', @use;
	$url .= "&inc=$inc" if $inc;
	$url .= $constraint if $constraint;
	return ($url, $fail);
}

sub _validate_browse_incs {
	my $self = shift;
	my $incs = shift;
	my @use;
	my $fail = [];

	for my $inc (@$incs){
		if ($inc ~~ @{$self->{_valid_browse_inc_params}}){
			push @use, $inc;
		} else {
			push @$fail, $inc;
		}
	}

	my $url = join '+', @use;
	return ($url, $fail);
}

sub _validate_params {
	my $self = shift;
	my $params = shift;

	foreach my $key (sort keys %{ $params }) {
		my $valid = 0;

		my @new_terms;
		foreach my $term (split /[\s\+,]/, $params->{$key}) {
			push @new_terms, URI::Escape::uri_escape_utf8($term);
		}

      $params->{$key} = join '+', @new_terms;

      if(lc($key) eq "inc") {
         foreach my $iparam (split /[\s,]/, $params->{INC}) {
              foreach my $vparam (@{ $self->{_valid_inc_params} }) {
                  if((lc($iparam) eq lc($vparam)) || ($iparam =~ m/^$vparam/)) {
                      $valid = 1;
                      last;
                  }
              }
          }
      } else {
          foreach my $vparam (@{ $self->{_valid_url_params} }) {
             if(lc($key) eq lc($vparam)) {
                $valid = 1;
                last;
             }
         }
      }

      if($valid == 0) {
         die "Invalid parameter : $key";
      }
   }

   return $params;
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
