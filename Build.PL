use Module::Build;
my $build = Module::Build->new
(
     module_name => 'WebService::MusicBrainz2',
     dist_abstract => 'Web service API to MusicBrainz database version 2 schema',
     license  => 'perl',
     requires => {
                  'perl'          => '5.7.0',
                  'XML::LibXML'   => '1.63',
                  'LWP::UserAgent' => '2.0',
                  'Class::Accessor' => '0.30',
                  'Test::More' => '0.88',
                  'URI' => '1.35',
                 },
     create_makefile_pl => 'traditional',
     dist_author => 'Joshua Lowe <jlowe@copper.net>',
     dist_version => '0.23',
     meta_merge => {
        resources => {
           repository => 'git://github.com/joshua-lowe/webservice-musicbrainz2.git'
        },
        keywords => [ qw/musicbrainz2 musicbrainz webservice/ ]
     },
);
$build->create_build_script;
