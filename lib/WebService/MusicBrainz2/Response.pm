package WebService::MusicBrainz2::Response;

use strict;
use XML::LibXML;

our $VERSION = '0.23';

=head1 NAME

WebService::MusicBrainz2::Response

=head1 SYNOPSIS

=head1 DESCRIPTION

This module will hide the details of the XML web service response and provide an API to query the XML data which has been returned.  This module is responsible for parsing the XML web service response and instantiating objects to provide access to the details of the response.

=head1 METHODS

=head2 new

This method is the constructor and it will call for  initialization.

=cut

sub new {
	my $class = shift;
	my %params = @_;
	my $self = {};

	bless $self, $class;

	$self->{_xml} = $params{XML} || die "XML parameter required";

	$self->_load_xml;

	$self->_init;

   return $self;
}

sub _load_xml {
	my $self = shift;

	my $parser = XML::LibXML->new;

	my $document = $parser->parse_string($self->{_xml}) or die "Failure to parse XML";

	my $root = $document->getDocumentElement;

	my $xpc = XML::LibXML::XPathContext->new($root);

	$xpc->registerNs('mmd', $root->getAttribute('xmlns'));
	$xpc->registerNs('ext', $root->getAttribute('xmlns:ext')) if $root->getAttribute('xmlns:ext');

	$self->{_xmlobj} = $xpc;
	$self->{_xmlroot} = $root;

	return;
}

=head2 xpc

=cut

sub xpc { shift->{_xmlobj} }

=head2 as_xml

This method returns the raw XML from the MusicBrainz2 web service response.

=cut

sub as_xml { shift->{_xmlroot}->toString; }

sub _init {
	my $self = shift;

	my $xpc = $self->xpc || return;

	my ($xArtist) = $xpc->findnodes('mmd:artist[1]');
	my ($xArtistList) = $xpc->findnodes('mmd:artist-list[1]');
	my ($xRecording) = $xpc->findnodes('mmd:recording[1]');
	my ($xRecordingList) = $xpc->findnodes('mmd:recording-list[1]');
	my ($xRelease) = $xpc->findnodes('mmd:release[1]');
	my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]');
	my ($xReleaseGroup) = $xpc->findnodes('mmd:release-group[1]');
	my ($xReleaseGroupList) = $xpc->findnodes('mmd:release-group-list[1]');
	my ($xWork) = $xpc->findnodes('mmd:work[1]');
	my ($xWorkList) = $xpc->findnodes('mmd:work-list[1]');
	my ($xLabel) = $xpc->findnodes('mmd:label[1]');
	my ($xLabelList) = $xpc->findnodes('mmd:label-list[1]');

	require WebService::MusicBrainz2::Response::Metadata;
	my $metadata = WebService::MusicBrainz2::Response::Metadata->new;

	$metadata->generator($xpc->find('@generator')->pop->getValue) if $xpc->find('@generator');
	$metadata->created($xpc->find('@created')->pop->getValue) if $xpc->find('@created');
	$metadata->score($xpc->find('@ext:score')->pop->getValue) if $xpc->lookupNs('ext') && $xpc->find('@ext:score');

	$metadata->artist($self->_create_artist($xArtist)) if $xArtist;
	$metadata->artist_list($self->_create_artist_list($xArtistList)) if $xArtistList;
	$metadata->recording($self->_create_recording($xRecording)) if $xRecording;
	$metadata->recording_list($self->_create_recording_list($xRecordingList)) if $xRecordingList;
	$metadata->release($self->_create_release($xRelease)) if $xRelease;
	$metadata->release_list($self->_create_release_list($xReleaseList)) if $xReleaseList;
	$metadata->release_group($self->_create_release_group($xReleaseGroup)) if $xReleaseGroup;
	$metadata->release_group_list($self->_create_release_group_list($xReleaseGroupList)) if $xReleaseGroupList;
	$metadata->work($self->_create_track($xWork)) if $xWork;
	$metadata->work_list($self->_create_work_list($xWorkList)) if $xWorkList;
	$metadata->label($self->_create_label($xLabel)) if $xLabel;
	$metadata->label_list($self->_create_label_list($xLabelList)) if $xLabelList;

	$self->{_metadata_cache} = $metadata;
}

=head2 generator

This method will return an optional value of the generator.

=cut

sub generator {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->generator;
}

=head2 created

This method will return an optional value of the created date.

=cut

sub created {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->created;
}

=head2 score

This method will return an optional value of the relevance score.

=cut

sub score {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->score;
}

=head2 metadata

This method will return an Response::Metadata object.

=cut

sub metadata {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata;
}

=head2 artist

This method will return an Response::Artist object.

=cut

sub artist {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist = $metadata->artist_list ? $metadata->artist_list->artists->[0] : $metadata->artist;

   return $artist;
}

=head2 artist_list

This method will return a reference to the Response::ArtistList object in a scalar context.  If in a array context, an array of Response::Artist objects will be returned.

=cut

sub artist_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist_list = $metadata->artist_list;

   return wantarray ? @{ $artist_list->artists } : $artist_list;
}

=head2 release

This method will return an Reponse::Release object;.

=cut

sub release {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release = $metadata->release_list ? $metadata->release_list->releases->[0] : $metadata->release;

   return $release;
}

=head2 release_list

This method will return a reference to the Response::ReleaseList object in a scalar context.  If in a array context, an array of Response::Release objects will be returned.

=cut

sub release_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_list = $metadata->release_list;

   return wantarray ? @{ $release_list->releases } : $release_list;
}

=head2 release_group

This method will return an Reponse::Release object;.

=cut

sub release_group {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_group = $metadata->release_group_list ? $metadata->release_group_list->release_groups->[0] : $metadata->release_group;

   return $release_group;
}

=head2 release_group_list

This method will return a reference to the Response::ReleaseList object in a scalar context.  If in a array context, an array of Response::Release objects will be returned.

=cut

sub release_group_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_group_list = $metadata->release_group_list;

   return wantarray ? @{ $release_group_list->release_groups } : $release_group_list;
}

=head2 recording

This method will return an Reponse::Release object;.

=cut

sub recording {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $recording = $metadata->recording_list ? $metadata->recording_list->recording->[0] : $metadata->recording;

   return $recording;
}

=head2 recording_list

This method will return a reference to the Response::ReleaseList object in a scalar context.  If in a array context, an array of Response::Release objects will be returned.

=cut

sub recording_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $recording_list = $metadata->recording_list;

   return wantarray ? @{ $recording_list->recordings } : $recording_list;
}

=head2 work

This method will return an Response::Work object.

=cut

sub work {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $work = $metadata->work_list ? $metadata->work_list->works->[0] : $metadata->work;

   return $work;
}

=head2 work_list

This method will return a reference to the Response::WorkList object in a scalar context.  If in a array context, an array of Response::Track objects will be returned.

=cut

sub work_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $work_list = $metadata->work_list;

   return wantarray ? @{ $work_list->works } : $work_list;
}

=head2 label

This method will return an Response::Label object.

=cut

sub label {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $label = $metadata->label_list ? $metadata->label_list->labels->[0] : $metadata->label;

   return $label;
}

=head2 label_list

This method will return a reference to the Response::LabelList object in a scalar context.  If in a array context, an array of Response::Label objects will be returned.

=cut

sub label_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $label_list = $metadata->label_list;

   return wantarray ? @{ $label_list->labels } : $label_list;
}

sub _create_artist {
	my $self = shift;
	my ($xArtist) = @_;

	my $xpc = $self->xpc;

	my ($xSortName) = $xpc->findnodes('mmd:sort-name[1]', $xArtist);
	my ($xName) = $xpc->findnodes('mmd:name[1]', $xArtist);
	my ($xDisambiguation) = $xpc->findnodes('mmd:disambiguation[1]', $xArtist);
	my ($xGender) = $xpc->findnodes('mmd:gender[1]', $xArtist);
	my ($xCountry) = $xpc->findnodes('mmd:country[1]', $xArtist);

	my ($xIpi) = $xpc->findnodes('mmd:ipi[1]', $xArtist);
	my ($xIpiList) = $xpc->findnodes('mmd:ipi-list[1]', $xArtist);
	my ($xLifeSpan) = $xpc->findnodes('mmd:life-span[1]', $xArtist);
	my ($xAliasList) = $xpc->findnodes('mmd:alias-list[1]', $xArtist);

	my ($xRecordingList) = $xpc->findnodes('mmd:recording-list[1]', $xArtist);
	my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xArtist);
	my ($xReleaseGroupList) = $xpc->findnodes('mmd:release-group-list[1]', $xArtist);
	my ($xWorkList) = $xpc->findnodes('mmd:work-list[1]', $xArtist);

	my @xRelationList = $xpc->findnodes('mmd:relation-list', $xArtist);

	my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xArtist);
	my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xArtist);

	require WebService::MusicBrainz2::Response::Artist;
	my $artist = WebService::MusicBrainz2::Response::Artist->new;

	$artist->id($xArtist->getAttribute('id')) if $xArtist->getAttribute('id');
	$artist->type($xArtist->getAttribute('type')) if $xArtist->getAttribute('type');
	$artist->score($xArtist->getAttribute('ext:score')) if $xArtist->getAttribute('ext:score');

	$artist->sort_name($xSortName->textContent) if $xSortName;
	$artist->name($xName->textContent) if $xName;
	$artist->disambiguation($xDisambiguation->textContent) if $xDisambiguation;
	$artist->gender($xGender->textContent) if $xGender;
	$artist->country($xCountry->textContent) if $xCountry;

	$artist->ipi($xIpi->textContent) if $xIpi;
	$artist->ipi_list($self->_create_ipi_list($xIpiList)) if $xIpiList;
	$artist->life_span($self->_create_life_span($xLifeSpan)) if $xLifeSpan;
	$artist->alias_list($self->_create_alias_list($xAliasList)) if $xAliasList;

	$artist->recording_list($self->_create_recording_list($xRecordingList)) if $xRecordingList;
	$artist->release_list($self->_create_release_list($xReleaseList)) if $xReleaseList;
	$artist->release_group_list($self->_create_release_group_list($xReleaseGroupList)) if $xReleaseGroupList;
	$artist->work_list($self->_create_work_list($xWorkList)) if $xWorkList;

	my $relationLists = $self->_create_relation_lists( \@xRelationList );
	$artist->relation_list( $relationLists->[0] ) if $relationLists;
	$artist->relation_lists( $relationLists ) if $relationLists;

	$artist->tag_list( $self->_create_tag_list( $xTagList ) ) if $xTagList;
	$artist->rating( $self->_create_rating( $xRating ) ) if $xRating;

	return $artist;
}

sub _create_artist_list {
	my $self = shift;
	my ($xArtistList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::ArtistList;
	my $artist_list = WebService::MusicBrainz2::Response::ArtistList->new;

	$artist_list->count($xArtistList->getAttribute('count')) if $xArtistList->getAttribute('count');
	$artist_list->offset($xArtistList->getAttribute('offset'));

	my $artists = [];

	foreach my $xArtist ($xpc->findnodes('mmd:artist', $xArtistList)) {
		my $artist = $self->_create_artist($xArtist);
		push @$artists, $artist;
	}

	$artist_list->artists($artists);

	return $artist_list;
}

sub _create_life_span {
	my $self = shift;
	my ($xLifeSpan) = @_;

	my $xpc = $self->xpc;

	my ($xBegin) = $xpc->findnodes('mmd:begin[1]', $xLifeSpan);
	my ($xEnd) = $xpc->findnodes('mmd:end[1]', $xLifeSpan);
	my ($xEnded) = $xpc->findnodes('mmd:ended[1]', $xLifeSpan);

	require WebService::MusicBrainz2::Response::LifeSpan;
	my $life_span = WebService::MusicBrainz2::Response::LifeSpan->new;

	$life_span->begin($xBegin->textContent) if $xBegin;
	$life_span->end($xEnd->textContent) if $xEnd;
	$life_span->ended($xEnded->textContent) if $xEnded;

	return $life_span;

}

sub _create_ipi_list {
	my $self = shift;
	my ($xIpiList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::IpiList;
	my $ipi_list =  WebService::MusicBrainz2::Response::IpiList->new;

	my $ipis = [];

	for my $xIpi ($xpc->findnodes('mmd:ipi', $xIpiList)){
		my $ipi = $xIpi->textContent;
		push @$ipis, $ipi;
	}

	$ipi_list->ipis($ipis);

	return $ipi_list;
}

sub _create_recording_list {
   my $self = shift;
   my ($xRecordingList) = @_;

   my $xpc = $self->xpc;

   require WebService::MusicBrainz2::Response::RecordingList;
   my $recording_list = WebService::MusicBrainz2::Response::RecordingList->new;

   $recording_list->count($xRecordingList->getAttribute('count')) if $xRecordingList->getAttribute('count');
   $recording_list->offset($xRecordingList->getAttribute('offset'));

   my $recordings = [];

   foreach my $xRecording ($xpc->findnodes('mmd:recording', $xRecordingList)) {
       my $recording = $self->_create_recording($xRecording);

       push @$recordings, $recording;
   }

   $recording_list->recordings($recordings);

   return $recording_list;
}

sub _create_recording {
	my $self = shift;
	my ($xRecording) = @_;

	my $xpc = $self->xpc;

	my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xRecording);
	my ($xLength) = $xpc->findnodes('mmd:length[1]', $xRecording);
	my ($xArtistCredit) = $xpc->findnodes('mmd:artist-credit[1]', $xRecording);
	my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xRecording);
	my ($xPuidList) = $xpc->findnodes('mmd:puid-list[1]', $xRecording);
	my ($xIsrcList) = $xpc->findnodes('mmd:isrc-list[1]', $xRecording);
	my @xRelationList = $xpc->findnodes('mmd:relation-list', $xRecording);
	my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xRecording);
	my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xRecording);
	my ($xUserTagList) = $xpc->findnodes('mmd:user-tag-list[1]', $xRecording);
	my ($xUserRating) = $xpc->findnodes('mmd:user-rating[1]', $xRecording);


	require WebService::MusicBrainz2::Response::Recording;
	my $recording = WebService::MusicBrainz2::Response::Recording->new;

	$recording->id($xRecording->getAttribute('id')) if $xRecording->getAttribute('id');
	$recording->score($xRecording->getAttribute('ext:score')) if $xRecording->getAttribute('ext:score');
	$recording->title($xTitle->textContent) if $xTitle;
	$recording->length($xLength->textContent) if $xLength;
	$recording->artist_credit($self->_create_artist_credit($xArtistCredit)) if $xArtistCredit;
	$recording->release_list($self->_create_release_list($xReleaseList)) if $xReleaseList;
	$recording->puid_list($self->_create_puid_list($xPuidList)) if $xPuidList;
	$recording->isrc_list($self->_create_isrc_list($xIsrcList)) if $xIsrcList;
	$recording->tag_list($self->_create_tag_list($xTagList)) if $xTagList;
	$recording->rating($self->_create_rating($xRating)) if $xRating;
	$recording->user_tag_list($self->_create_tag_list($xUserTagList)) if $xUserTagList;
	$recording->user_rating($self->_create_rating($xUserRating)) if $xUserRating;

	my $relationLists = $self->_create_relation_lists(\@xRelationList);
	$recording->relation_list($relationLists->[0]) if $relationLists;
	$recording->relation_lists($relationLists) if $relationLists;

	return $recording;
}

sub _create_work_list {
	my $self = shift;
	my ($xWorkList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::WorkList;
	my $work_list = WebService::MusicBrainz2::Response::WorkList->new;

	my $works = [];

	for my $xWork ($xpc->findnodes('mmd:work', $xWorkList)){
		my $work = $self->_create_work($xWorkList);
		push @$works, $work;
	}

	$work_list->count($xWorkList->getAttribute('count')) if $xWorkList->getAttribute('count');
	$work_list->offset($xWorkList->getAttribute('offset')) if $xWorkList->getAttribute('offset');
	$work_list->works($works);

	return $work_list;
}

sub _create_work {
	my $self = shift;
	my ($xWork) = @_;

	my $xpc = $self->xpc;

	my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xWork);
	my @RelationList = $xpc->findnodes('mmd:relation-list', $xWork);

	require WebService::MusicBrainz2::Response::Work;
	my $work = WebService::MusicBrainz2::Response::Work->new;

	$work->id($xWork->getAttribute('id')) if $xWork->getAttribute('id');
	$work->title($xTitle->textContent) if $xTitle;
	$work->relation_lists($self->_create_relation_lists(\@RelationList)) if \@RelationList;

	return $work;
}

sub _create_artist_credit {
	my $self = shift;
	my ($xCredits) = @_;

	my $xpc = $self->xpc;

	my @xNameCredits = $xpc->findnodes('mmd:name-credit', $xCredits);

	my $credits = [];
	require WebService::MusicBrainz2::Response::ArtistCredit;
	my $artist_credit = WebService::MusicBrainz2::Response::ArtistCredit->new;

	for my $xName (@xNameCredits) {
		push @$credits, $self->_create_name_credit($xName);
	}

	$artist_credit->name_credits($credits);

	return $artist_credit;
}

sub _create_name_credit {
	my $self = shift;
	my ($xNameCredit) = @_;

	my $xpc = $self->xpc;

	my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xNameCredit);

	require WebService::MusicBrainz2::Response::NameCredit;
	my $name = WebService::MusicBrainz2::Response::NameCredit->new;

	$name->artist($self->_create_artist($xArtist)) if($xArtist);
	$name->joinphrase($xNameCredit->getAttribute('joinphrase')) if $xNameCredit->getAttribute('joinphrase');

	return $name;
}

sub _create_release {
	my $self = shift;
	my ($xRelease) = @_;

	my $xpc = $self->xpc;

	my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xRelease);
	my ($xASIN) = $xpc->findnodes('mmd:asin[1]', $xRelease);

	my ($xStatus) = $xpc->findnodes('mmd:status[1]', $xRelease);
	my ($xQuality) = $xpc->findnodes('mmd:quality[1]', $xRelease);
	my ($xDisambiguation) = $xpc->findnodes('mmd:disambiguation[1]', $xRelease);

	my ($xDate) = $xpc->findnodes('mmd:date[1]', $xRelease);
	my ($xCountry) = $xpc->findnodes('mmd:country[1]', $xRelease);
	my ($xBarcode) = $xpc->findnodes('mmd:barcode[1]', $xRelease);

	my ($xTextRep) = $xpc->findnodes('mmd:text-representation[1]', $xRelease);

	my ($xArtistCredit) = $xpc->findnodes('mmd:artist-credit[1]', $xRelease);
	my ($xReleaseGroup) = $xpc->findnodes('mmd:release-group[1]', $xRelease);

	my ($xCoverArtArchive) = $xpc->findnodes('mmd:cover-art-archive[1]', $xRelease);
	my ($xLabelInfoList) = $xpc->findnodes('mmd:label-info-list[1]', $xRelease);
	my ($xMediumList) = $xpc->findnodes('mmd:medium-list[1]', $xRelease);

	my @xRelationList = $xpc->findnodes('mmd:relation-list', $xRelease);

	my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xRelease);
	my ($xUserTagList) = $xpc->findnodes('mmd:user-tag-list[1]', $xRelease);
	my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xRelease);
	my ($xUserRating) = $xpc->findnodes('mmd:user-rating[1]', $xRelease);

	require WebService::MusicBrainz2::Response::Release;
	my $release = WebService::MusicBrainz2::Response::Release->new();

	$release->id($xRelease->getAttribute('id')) if $xRelease->getAttribute('id');
	$release->title($xTitle->textContent) if $xTitle;
	$release->asin($xASIN->textContent) if $xASIN;

	$release->status($xStatus->textContent) if $xStatus;
	$release->quality($xQuality->textContent) if $xQuality;
	$release->disambiguation($xDisambiguation->textContent) if $xDisambiguation;

	$release->date($xDate->textContent) if $xDate;
	$release->country($xCountry->textContent) if $xCountry;
	$release->barcode($xBarcode->textContent) if $xBarcode;

	$release->text_rep($self->_create_text_rep($xTextRep)) if $xTextRep;

	$release->artist_credit($self->_create_artist_credit($xArtistCredit)) if $xArtistCredit;
	$release->release_group($self->_create_release_group($xReleaseGroup)) if $xReleaseGroup;

	$release->cover_art_archive($self->_create_cover_art_archive($xCoverArtArchive)) if $xCoverArtArchive;
	$release->label_info_list($self->_create_label_info_list($xLabelInfoList)) if $xLabelInfoList;
	$release->medium_list($self->_create_medium_list($xMediumList)) if $xMediumList;

	my $relationLists = $self->_create_relation_lists(\@xRelationList);
	$release->relation_list($relationLists->[0]) if $relationLists;
	$release->relation_lists($relationLists) if $relationLists;

	$release->tag_list($self->_create_tag_list($xTagList)) if $xTagList;
	$release->user_tag_list($self->_create_user_tag_list($xUserTagList)) if $xUserTagList;
	$release->rating($self->_create_rating($xRating)) if $xRating;
	$release->user_rating($self->_create_user_rating($xUserRating)) if $xUserRating;

	$release->score( $xRelease->getAttribute('ext:score') ) if $xRelease->getAttribute('ext:score');

	return $release;
}

sub _create_text_rep {
	my $self = shift;
	my ($xTextRep) = @_;

	my $xpc = $self->xpc;

	my ($xLanguage) = $xpc->findnodes('mmd:language[1]', $xTextRep);
	my ($xScript) = $xpc->findnodes('mmd:script[1]', $xTextRep);

	require WebService::MusicBrainz2::Response::TextRep;
	my $text_rep = WebService::MusicBrainz2::Response::TextRep->new;

	$text_rep->language($xLanguage->textContent) if $xLanguage;
	$text_rep->script($xScript->textContent) if $xScript;

	return $text_rep;
}

sub _create_cover_art_archive {
	my $self = shift;
	my ($xCoverArtArchive) = @_;

	my $xpc = $self->xpc;

	my ($xArtwork) = $xpc->findnodes('mmd:artwork[1]', $xCoverArtArchive);
	my ($xCount) = $xpc->findnodes('mmd:count[1]', $xCoverArtArchive);
	my ($xFront) = $xpc->findnodes('mmd:front[1]', $xCoverArtArchive);
	my ($xBack) = $xpc->findnodes('mmd:back[1]', $xCoverArtArchive);

	require WebService::MusicBrainz2::Response::CoverArtArchive;
	my $cover_art_archive = WebService::MusicBrainz2::Response::CoverArtArchive->new;

	$cover_art_archive->artwork($xArtwork->textContent) if ($xArtwork);
	$cover_art_archive->count($xCount->textContent) if ($xCount);
	$cover_art_archive->front($xFront->textContent) if ($xFront);
	$cover_art_archive->back($xBack->textContent) if ($xBack);

	return $cover_art_archive;
}

sub _create_label {
	my $self = shift;
	my ($xLabel) = @_;

	my $xpc = $self->xpc;

	my ($xName) = $xpc->findnodes('mmd:name[1]', $xLabel);
	my ($xSortName) = $xpc->findnodes('mmd:sort-name[1]', $xLabel);
	my ($xLabelCode) = $xpc->findnodes('mmd:label-code[1]', $xLabel);
	my ($xDisambiguation) = $xpc->findnodes('mmd:disambiguation[1]', $xLabel);
	my ($xCountry) = $xpc->findnodes('mmd:country[1]', $xLabel);
	my ($xLifeSpan) = $xpc->findnodes('mmd:life-span[1]', $xLabel);
	my ($xAliasList) = $xpc->findnodes('mmd:alias-list[1]', $xLabel);
	my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xLabel);

	my @xRelationList = $xpc->findnodes('mmd:relation-list', $xLabel);

	my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xLabel);
	my ($xUserTagList) = $xpc->findnodes('mmd:user-tag-list[1]', $xLabel);
	my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xLabel);
	my ($xUserRating) = $xpc->findnodes('mmd:user-rating[1]', $xLabel);

	require WebService::MusicBrainz2::Response::Label;
	my $label= WebService::MusicBrainz2::Response::Label->new();

	$label->id($xLabel->getAttribute('id')) if $xLabel->getAttribute('id');
	$label->type($xLabel->getAttribute('type')) if $xLabel->getAttribute('type');

	$label->name($xName->textContent) if $xName;
	$label->sort_name($xSortName->textContent) if $xSortName;
	$label->label_code($xLabelCode->textContent) if $xLabelCode;
	$label->disambiguation($xDisambiguation->textContent) if $xDisambiguation;
	$label->country($xCountry->textContent) if $xCountry;
	$label->life_span($self->_create_life_span($xLifeSpan)) if $xLifeSpan;
	$label->alias_list($self->_create_alias_list($xAliasList)) if $xAliasList;
	$label->release_list($self->_create_release_list($xReleaseList)) if $xReleaseList;

	$label->tag_list($self->_create_tag_list($xTagList)) if $xTagList;
	$label->user_tag_list($self->_create_user_tag_list($xUserTagList)) if $xUserTagList;
	$label->rating($self->_create_rating($xRating)) if $xRating;
	$label->user_rating($self->_create_user_rating($xUserRating)) if $xUserRating;

	$label->score($xLabel->getAttribute('ext:score')) if $xLabel->getAttribute('ext:score');

	my $relationLists = $self->_create_relation_lists( \@xRelationList );
	$label->relation_list( $relationLists->[0] ) if $relationLists;
	$label->relation_lists( $relationLists ) if $relationLists;
   
	return $label;
}

sub _create_label_info_list {
	my $self = shift;
	my ($xLabelInfoList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::LabelInfoList;
	my $label_info_list = WebService::MusicBrainz2::Response::LabelInfoList->new;

	$label_info_list->count($xLabelInfoList->getAttribute('count')) if $xLabelInfoList->getAttribute('count');
	$label_info_list->offset($xLabelInfoList->getAttribute('offset'));
   
	my $labels = [];

	foreach my $xLabelInfo ($xpc->findnodes('mmd:label-info', $xLabelInfoList)) {
		my $label = $self->_create_label_info($xLabelInfo);
		push @$labels, $label;
	}

	$label_info_list->labels($labels);

	return $label_info_list;
}

sub _create_label_info {
	my $self = shift;
	my ($xLabelInfo) = @_;

	my $xpc = $self->xpc;

	my ($xCatalog) = $xpc->findnodes('mmd:catalog-number[1]', $xLabelInfo);
	my ($xLabel) = $xpc->findnodes('mmd:label[1]', $xLabelInfo);

	require WebService::MusicBrainz2::Response::LabelInfo;
	my $label_info = WebService::MusicBrainz2::Response::LabelInfo->new;

	$label_info->catalog_number($xCatalog->textContent) if $xCatalog;
	$label_info->label($self->_create_label($xLabel)) if $xLabel;

	return $label_info;
}

sub _create_label_list {
	my $self = shift;
	my ($xLabelList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::LabelList;
	my $label_list = WebService::MusicBrainz2::Response::LabelList->new;

	$label_list->count($xLabelList->getAttribute('count')) if $xLabelList->getAttribute('count');
	$label_list->offset($xLabelList->getAttribute('offset'));
   
	my $labels = [];

	foreach my $xLabel ($xpc->findnodes('mmd:label', $xLabelList)) {
		my $label = $self->_create_label($xLabel);
		push @$labels, $label;
	}

	$label_list->labels($labels);

	return $label_list;
}

sub _create_medium_list {
	my $self = shift;
	my ($xMediumList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::MediumList;
	my $medium_list = WebService::MusicBrainz2::Response::MediumList->new;

	my $mediums = [];

	for my $xMedium ($xpc->findnodes('mmd:medium', $xMediumList)){
		my $medium = $self->_create_medium($xMedium);
		push @$mediums, $medium;
	}

	$medium_list->count($xMediumList->getAttribute('count')) if $xMediumList->getAttribute('count');
	$medium_list->mediums($mediums);

	return $medium_list;
}

sub _create_medium {
	my $self = shift;
	my ($xMedium) = @_;

	my $xpc = $self->xpc;

	my ($xPosition) = $xpc->findnodes('mmd:position[1]', $xMedium);
	my ($xFormat) = $xpc->findnodes('mmd:format[1]', $xMedium);
	my ($xDiscList) = $xpc->findnodes('mmd:disc-list[1]', $xMedium);
	my ($xTrackList) = $xpc->findnodes('mmd:track-list[1]', $xMedium);

	require WebService::MusicBrainz2::Response::Medium;
	my $medium = WebService::MusicBrainz2::Response::Medium->new;

	$medium->position($xPosition->textContent) if $xPosition;
	$medium->format($xFormat->textContent) if $xFormat;
	$medium->disc_list($self->_create_disc_list($xDiscList)) if $xDiscList;
	$medium->track_list($self->_create_track_list($xTrackList)) if $xTrackList;

	return $medium;
}

sub _create_track_list {
	my $self = shift;
	my ($xTrackList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::TrackList;
	my $track_list = WebService::MusicBrainz2::Response::TrackList->new;

	$track_list->count( $xTrackList->getAttribute('count') ) if $xTrackList->getAttribute('count');
	$track_list->offset( $xTrackList->getAttribute('offset') );

	my $tracks;

	foreach my $xTrack ($xpc->findnodes('mmd:track', $xTrackList)) {
		my $track = $self->_create_track( $xTrack );
		push @$tracks, $track;
	}

	$track_list->tracks($tracks);

	return $track_list;
}

sub _create_track {
	my $self = shift;
	my ($xTrack) = @_;

	my $xpc = $self->xpc;

	my ($xPosition) = $xpc->findnodes('mmd:position[1]', $xTrack);
	my ($xNumber) = $xpc->findnodes('mmd:number[1]', $xTrack);
	my ($xLength) = $xpc->findnodes('mmd:length[1]', $xTrack);
	my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xTrack);
	my ($xRecording) = $xpc->findnodes('mmd:recording[1]', $xTrack);

	require WebService::MusicBrainz2::Response::Track;
	my $track= WebService::MusicBrainz2::Response::Track->new();

	$track->position($xPosition->textContent) if $xPosition;
	$track->number($xNumber->textContent) if $xNumber;
	$track->length($xLength->textContent) if $xLength;
	$track->title($xTitle->textContent) if $xTitle;
	$track->recording($self->_create_recording($xRecording)) if $xRecording;

	return $track;
}

sub _create_alias {
	my $self = shift;
	my ($xAlias) = @_;

	require WebService::MusicBrainz2::Response::Alias;
	my $alias = WebService::MusicBrainz2::Response::Alias->new;

	$alias->type($xAlias->getAttribute('type')) if $xAlias->getAttribute('type');
	$alias->script($xAlias->getAttribute('script')) if $xAlias->getAttribute('script');
	$alias->sort_name($xAlias->getAttribute('sort-name')) if $xAlias->getAttribute('sort-name');
	$alias->primary($xAlias->getAttribute('primary')) if $xAlias->getAttribute('primary');
	$alias->locale($xAlias->getAttribute('locale')) if $xAlias->getAttribute('locale');
	$alias->text($xAlias->textContent) if $xAlias->textContent;

	return $alias;
}

sub _create_alias_list {
   my $self = shift;
   my ($xAliasList) = @_;

   my $xpc = $self->xpc;

   require WebService::MusicBrainz2::Response::AliasList;

   my $alias_list = WebService::MusicBrainz2::Response::AliasList->new;

   $alias_list->count( $xAliasList->getAttribute('count') ) if $xAliasList->getAttribute('count');
   $alias_list->offset( $xAliasList->getAttribute('offset') );

   my @aliases;

   foreach my $xAlias ($xpc->findnodes('mmd:alias', $xAliasList)) {
       my $alias = $self->_create_alias($xAlias);

       push @aliases, $alias if defined($alias);
   }

   $alias_list->aliases( \@aliases );

   return $alias_list;
}

sub _create_attribute_list {
	my $self = shift;
	my ($xAttributeList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::AttributeList;
	my $attribute_list = WebService::MusicBrainz2::Response::AttributeList->new;

	$attribute_list->count($xAttributeList->getAttribute('count')) if $xAttributeList->getAttribute('count');
	$attribute_list->offset($xAttributeList->getAttribute('offset')) if $xAttributeList->getAttribute('offset');

	my $attributes = [];

	for my $xAttribute ($xpc->findnodes('mmd:attribute', $xAttributeList)){
		my $attribute = $self->_create_attribute($xAttribute);
		push @$attributes, $attribute if($attribute);
	}

	$attribute_list->attributes($attributes);

	return $attribute_list

}

sub _create_attribute {
	my $self = shift;
	my $xAttribute = shift;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::Attribute;
	my $attribute = WebService::MusicBrainz2::Response::Attribute->new;

	$attribute->text($xAttribute->textContent) if $xAttribute;

	return $attribute;
}

sub _create_relation {
	my $self = shift;
	my ($xRelation) = @_;

	my $xpc = $self->xpc;

	my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xRelation);
	my ($xRecording) = $xpc->findnodes('mmd:recording[1]', $xRelation);
	my ($xRelease) = $xpc->findnodes('mmd:release[1]', $xRelation);
	my ($xReleaseGroup) = $xpc->findnodes('mmd:release-group[1]', $xRelation);
	my ($xWork) = $xpc->findnodes('mmd:work[1]', $xRelation);
	my ($xLabel) = $xpc->findnodes('mmd:label[1]', $xRelation);

	my ($xAttributeList) = $xpc->findnodes('mmd:attribute-list[1]', $xRelation);

	my ($xTarget) = $xpc->findnodes('mmd:target[1]', $xRelation);
	my ($xBegin) = $xpc->findnodes('mmd:begin[1]', $xRelation);
	my ($xEnd) = $xpc->findnodes('mmd:end[1]', $xRelation);
	my ($xEnded) = $xpc->findnodes('mmd:ended[1]', $xRelation);
	my ($xDirection) = $xpc->findnodes('mmd:direction[1]', $xRelation);

	require WebService::MusicBrainz2::Response::Relation;
	my $relation = WebService::MusicBrainz2::Response::Relation->new;

	$relation->type($xRelation->getAttribute('type')) if $xRelation->getAttribute('type');

	$relation->artist($self->_create_artist($xArtist)) if $xArtist;
	$relation->recording($self->_create_recording($xRecording)) if $xRecording;
	$relation->release($self->_create_release($xRelease)) if $xRelease;
	$relation->release_group($self->_create_release_group($xReleaseGroup)) if $xReleaseGroup;
	$relation->work($self->_create_work($xWork)) if $xWork;
	$relation->label($self->_create_label($xLabel)) if $xLabel;

	$relation->attributes($self->_create_attribute_list($xAttributeList)) if $xAttributeList;

	$relation->target($xTarget->textContent) if $xTarget;
	$relation->begin($xBegin->textContent) if $xBegin;
	$relation->end($xEnd->textContent) if $xEnd;
	$relation->ended($xEnded->textContent) if $xEnded;
	$relation->direction($xDirection->textContent) if $xDirection;

	$relation->score($xRelation->getAttribute('ext:score') ) if $xRelation->getAttribute('ext:score');

	return $relation;
}

sub _create_relation_lists {
	my $self = shift;
	my ($xRelationLists) = @_;

	my $relation_lists = [];

	if($xRelationLists && scalar(@{$xRelationLists}) > 0) {
		map { push @$relation_lists, $self->_create_relation_list($_) } @$xRelationLists;
	}

	return scalar(@$relation_lists) > 0 ? $relation_lists : undef;
}

sub _create_relation_list {
	my $self = shift;
	my ($xRelationList) = @_;

	my $xpc = $self->xpc;

	require WebService::MusicBrainz2::Response::RelationList;
	my $relation_list = WebService::MusicBrainz2::Response::RelationList->new;

   $relation_list->target_type($xRelationList->getAttribute('target-type')) if $xRelationList->getAttribute('target-type');
   $relation_list->count($xRelationList->getAttribute('count')) if $xRelationList->getAttribute('count');
   $relation_list->offset($xRelationList->getAttribute('offset'));

   my $relations = [];

   foreach my $xRelation ($xpc->findnodes('mmd:relation', $xRelationList)) {
       my $relation = $self->_create_relation($xRelation);

       push @$relations, $relation if defined($relation);
   }

   $relation_list->relations($relations);

   return $relation_list;
}

sub _create_event {
   my $self = shift;
   my ($xEvent) = @_;

   my $xpc = $self->xpc();

   my ($xLabel) = $xpc->findnodes('mmd:label[1]', $xEvent);

   require WebService::MusicBrainz2::Response::ReleaseEvent;

   my $event = WebService::MusicBrainz2::Response::ReleaseEvent->new();

   $event->date( $xEvent->getAttribute('date') ) if $xEvent->getAttribute('date');
   $event->country( $xEvent->getAttribute('country') ) if $xEvent->getAttribute('country');
   $event->label( $self->_create_label($xLabel) ) if $xLabel;
   $event->catalog_number( $xEvent->getAttribute('catalog-number') ) if $xEvent->getAttribute('catalog-number');
   $event->barcode( $xEvent->getAttribute('barcode') ) if $xEvent->getAttribute('barcode');
   $event->format( $xEvent->getAttribute('format') ) if $xEvent->getAttribute('format');

   return $event;
}

sub _create_release_event_list {
   my $self = shift;
   my ($xReleaseEventList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz2::Response::ReleaseEventList;

   my $release_event_list = WebService::MusicBrainz2::Response::ReleaseEventList->new();

   $release_event_list->count( $xReleaseEventList->getAttribute('count') ) if $xReleaseEventList->getAttribute('count');
   $release_event_list->offset( $xReleaseEventList->getAttribute('offset') );

   my @events;

   foreach my $xEvent ($xpc->findnodes('mmd:event', $xReleaseEventList)) {
       my $event = $self->_create_event( $xEvent );
       push @events, $event;
   }

   # should use a date object here but cheating with cmp to reduce dependencies for now...
   my @sorted_events = sort { $a->date() cmp $b->date() } @events;

   $release_event_list->events( \@sorted_events );

   return $release_event_list;
}

sub _create_release_list {
   my $self = shift;
   my ($xReleaseList) = @_;

   my $xpc = $self->xpc;

   require WebService::MusicBrainz2::Response::ReleaseList;
   my $release_list = WebService::MusicBrainz2::Response::ReleaseList->new;

   $release_list->count($xReleaseList->getAttribute('count')) if $xReleaseList->getAttribute('count');
   $release_list->offset($xReleaseList->getAttribute('offset'));

   my $releases = [];

   foreach my $xRelease ($xpc->findnodes('mmd:release', $xReleaseList)) {
       my $release = $self->_create_release($xRelease);

       push @$releases, $release if defined($release);
   }

   $release_list->releases($releases);

   return $release_list;
}

sub _create_disc {
   my $self = shift;
   my ($xDisc) = @_;

   require WebService::MusicBrainz2::Response::Disc;

   my $disc = WebService::MusicBrainz2::Response::Disc->new();

   $disc->id( $xDisc->getAttribute('id') ) if $xDisc->getAttribute('id');
   $disc->sectors( $xDisc->getAttribute('sectors') ) if $xDisc->getAttribute('sectors');

   return $disc;
}

sub _create_disc_list {
   my $self = shift;
   my ($xDiscList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz2::Response::DiscList;

   my $disc_list = WebService::MusicBrainz2::Response::DiscList->new();

   my @discs;

   $disc_list->count( $xDiscList->getAttribute('count') ) if $xDiscList->getAttribute('count');
   $disc_list->offset( $xDiscList->getAttribute('offset') );

   foreach my $xDisc ($xpc->findnodes('mmd:disc', $xDiscList)) {
      my $disc = $self->_create_disc( $xDisc );
      push @discs, $disc;
   }

   $disc_list->discs( \@discs );

   return $disc_list;
}

sub _create_puid {
   my $self = shift;
   my ($xPuid) = @_;

   require WebService::MusicBrainz2::Response::Puid;

   my $puid = WebService::MusicBrainz2::Response::Puid->new();

   $puid->id( $xPuid->getAttribute('id') ) if $xPuid->getAttribute('id');

   return $puid;
}

sub _create_puid_list {
   my $self = shift;
   my ($xPuidList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz2::Response::PuidList;

   my $puid_list = WebService::MusicBrainz2::Response::PuidList->new();

   $puid_list->count( $xPuidList->getAttribute('count') ) if $xPuidList->getAttribute('count');
   $puid_list->offset( $xPuidList->getAttribute('offset') );

   my @puids;

   foreach my $xPuid ($xpc->findnodes('mmd:puid', $xPuidList)) {
       my $puid = $self->_create_puid( $xPuid );
       push @puids, $puid;
   }

   $puid_list->puids( \@puids );

   return $puid_list;
}

sub _create_tag {
   my $self = shift;
   my ($xTag) = @_;

   require WebService::MusicBrainz2::Response::Tag;
   my $tag = WebService::MusicBrainz2::Response::Tag->new();

   $tag->id( $xTag->getAttribute('id') ) if $xTag->getAttribute('id');
   $tag->count( $xTag->getAttribute('count') ) if $xTag->getAttribute('count');
   $tag->text( $xTag->textContent() ) if $xTag->textContent();

   return $tag;
}

sub _create_tag_list {
   my $self = shift;
   my ($xTagList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz2::Response::TagList;

   my $tag_list = WebService::MusicBrainz2::Response::TagList->new();

   $tag_list->count( $xTagList->getAttribute('count') ) if $xTagList->getAttribute('count');
   $tag_list->offset( $xTagList->getAttribute('offset') );

   my @tags;

   foreach my $xTag ($xpc->findnodes('mmd:tag', $xTagList)) {
       my $tag = $self->_create_tag( $xTag );
       push @tags, $tag;
   }

   $tag_list->tags( \@tags );

   return $tag_list;
}

sub _create_isrc {
   my $self = shift;
   my ($xIsrc) = @_;

   require WebService::MusicBrainz2::Response::ISRC;

   my $isrc = WebService::MusicBrainz2::Response::ISRC->new();

   $isrc->id( $xIsrc->getAttribute('id') ) if $xIsrc->getAttribute('id');

   return $isrc;
}

sub _create_isrc_list {
   my $self = shift;
   my ($xIsrcList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz2::Response::ISRCList;

   my $isrc_list = WebService::MusicBrainz2::Response::ISRCList->new();

   $isrc_list->count( $xIsrcList->getAttribute('count') ) if $xIsrcList->getAttribute('count');
   $isrc_list->offset( $xIsrcList->getAttribute('offset') );

   my @isrcs;

   foreach my $xIsrc ($xpc->findnodes('mmd:isrc', $xIsrcList)) {
       my $isrc = $self->_create_isrc( $xIsrc );
       push @isrcs, $isrc;
   }

   $isrc_list->isrcs( \@isrcs );

   return $isrc_list;
}

sub _create_release_group {
	my $self = shift;
	my ($xReleaseGroup) = @_;

	my $xpc = $self->xpc;

	my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xReleaseGroup);
	my ($xFirstReleaseDate) = $xpc->findnodes('mmd:first-release-date[1]', $xReleaseGroup);
	my ($xPrimaryType) = $xpc->findnodes('mmd:primary-type[1]', $xReleaseGroup);
	my ($xArtistCredit) = $xpc->findnodes('mmd:artist-credit[1]', $xReleaseGroup);
	my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xReleaseGroup);

	my @xRelationList = $xpc->findnodes('mmd:relation-list', $xReleaseGroup);

	my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xReleaseGroup);
	my ($xUserTagList) = $xpc->findnodes('mmd:user-tag-list[1]', $xReleaseGroup);
	my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xReleaseGroup);
	my ($xUserRating) = $xpc->findnodes('mmd:user-rating[1]', $xReleaseGroup);

	require WebService::MusicBrainz2::Response::ReleaseGroup;
	my $rel_group = WebService::MusicBrainz2::Response::ReleaseGroup->new;

	$rel_group->id($xReleaseGroup->getAttribute('id')) if $xReleaseGroup->getAttribute('id');
	$rel_group->type($xReleaseGroup->getAttribute('type')) if $xReleaseGroup->getAttribute('type');

	$rel_group->title($xTitle->textContent) if $xTitle;
	$rel_group->first_release_date($xFirstReleaseDate->textContent) if $xFirstReleaseDate;
	$rel_group->primary_type($xPrimaryType->textContent) if $xPrimaryType;

	$rel_group->artist_credit($self->_create_artist_credit($xArtistCredit)) if $xArtistCredit;
	$rel_group->release_list($self->_create_release_list($xReleaseList)) if $xReleaseList;

	my $relationLists = $self->_create_relation_lists(\@xRelationList);
	$rel_group->relation_lists($relationLists) if $relationLists;

	$rel_group->tag_list($self->_create_tag_list($xTagList)) if $xTagList;
	$rel_group->user_tag_list($self->_create_user_tag_list($xUserTagList)) if $xUserTagList;
	$rel_group->rating($self->_create_rating($xRating)) if $xRating;
	$rel_group->user_rating($self->_create_user_rating($xUserRating)) if $xUserRating;

	$rel_group->score($xReleaseGroup->getAttribute('ext:score')) if $xReleaseGroup->getAttribute('ext:score');

	return $rel_group;
}

sub _create_release_group_list {
   my $self = shift;
   my ($xReleaseGroupList) = @_;

   my $xpc = $self->xpc;

   require WebService::MusicBrainz2::Response::ReleaseGroupList;
   my $rel_group_list = WebService::MusicBrainz2::Response::ReleaseGroupList->new();

   $rel_group_list->count( $xReleaseGroupList->getAttribute('count') ) if $xReleaseGroupList->getAttribute('count');
   $rel_group_list->offset( $xReleaseGroupList->getAttribute('offset') );
   $rel_group_list->score( $xReleaseGroupList->getAttribute('ext:score') ) if $xReleaseGroupList->getAttribute('ext:score');

   my @rel_groups;

   foreach my $xReleaseGroup ($xpc->findnodes('mmd:release-group', $xReleaseGroupList)) {
       my $rel_group = $self->_create_release_group( $xReleaseGroup );
       push @rel_groups, $rel_group;
   }

   $rel_group_list->release_groups( \@rel_groups );

   return $rel_group_list;
}

sub _create_rating {
   my $self = shift;
   my ($xRating) = @_;

   require WebService::MusicBrainz2::Response::Rating;

   my $rating = WebService::MusicBrainz2::Response::Rating->new();

   $rating->votes_count( $xRating->getAttribute('votes-count') ) if $xRating->getAttribute('votes-count');
   $rating->value( $xRating->textContent() ) if $xRating->textContent();

   return $rating;
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
