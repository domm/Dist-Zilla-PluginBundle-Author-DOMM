package Dist::Zilla::PluginBundle::Author::DOMM;

# ABSTRACT: BeLike::DOMM when you zilla your dist

our $VERSION = 0.900;

# based on: Dist::Zilla::PluginBundle::Author::ETHER
# shorter: Dist::Zilla::PluginBundle::Author::CCM

use Moose;
use namespace::autoclean;
with qw(
  Dist::Zilla::Role::PluginBundle::Easy
  Dist::Zilla::Role::PluginBundle::PluginRemover
);
use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::Plugin::AutoPrereqs;
use Dist::Zilla::Plugin::CheckChangeLog;
use Dist::Zilla::Plugin::VersionFromModule;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::MetaConfig;
use Dist::Zilla::Plugin::MetaResources;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::CPANFile;
use Dist::Zilla::Plugin::GithubMeta;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::CopyFilesFromBuild;
use Dist::Zilla::Plugin::Run;

use List::Util qw(any);

has homepage => (
  is      => 'ro' ,
  isa     => 'Maybe[Str]' ,
  lazy    => 1 ,
  default => sub { $_[0]->payload->{homepage} } ,
);

my @never_gather = grep -e, qw(
    Makefile.PL README.md README.pod META.json
    cpanfile cpanfile.snapshot TODO CONTRIBUTING LICENCE LICENSE INSTALL
    local
);

sub configure {
    my $self = shift;

    $self->add_plugins(
        ['GatherDir' => {
            (@never_gather ? (exclude_filename => \@never_gather) : ()),
            exclude_match=>[qw(local)],
        }],
        'PruneCruft',
        'VersionFromModule',
        'ManifestSkip',
        'License',
        'MetaJSON',
        'ModuleBuild',
        'Manifest',
        'AutoPrereqs',
        'CPANFile',
        # script vs bin??
        (-d ($self->payload->{'ExecDir.dir'} // 'bin') || any { /^ExecDir\./ } keys %{ $self->payload })
            ? [ 'ExecDir' => { dir => 'bin' } ] : (),
        'ShareDir', # use similar trick as for ExecDir?
        'ExtraTests',
        'CheckChangeLog' ,
        'PodWeaver',
        'MetaConfig' ,
        'InstallGuide',
        'TestRelease',
        'ConfirmRelease',
        [ 'ReadmeAnyFromPod' => {
            type=>'markdown',
            filename=>'README.md',
            location=>'build',
        }],
        [ 'CopyFilesFromBuild' => { copy => 'README.md' } ],
        # TODO default homepage should be metacpan!
        ['GithubMeta' => {
            issues=>1,
            ($self->homepage ? (homepage => $self->homepage) : ()),
        }]
    );
}

1;

