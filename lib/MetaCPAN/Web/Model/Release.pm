package MetaCPAN::Web::Model::Release;
use strict;
use warnings;
use base 'MetaCPAN::Web::Model';

sub get {
  my ( $self, $author, $release ) = @_;
  $self->request(
    '/release/_search',
    { query  => { match_all => {} },
      filter => {
        and => [
          { term => { 'name' => $release } },
          { term => { author => $author } } ] } } );
}

sub recent {
  my $self = shift;
  $self->request(
    '/release/_search',
    { size  => 100,
      query => { match_all => {} },
      sort  => [ { 'date' => { order => "desc" } } ] } );
}

sub modules {
  my ( $self, $author, $release ) = @_;
  $self->request(
    '/file/_search',
    { query  => { match_all => {} },
      filter => {
        and => [
          { term => { release => $release } },
          { term => { author  => $author } },
          {
            or => [
              {
                and => [
                  { exists => { field                 => 'file.module.name' } },
                  { term   => { 'file.module.indexed' => \1 } } ]
              },
              {
                and => [
                  { exists => { field          => 'documentation' } },
                  { term   => { 'file.indexed' => \1 } } ] } ] } ]
      },
      size   => 999,
      sort   => ['documentation'],
      fields => [qw(documentation _source.abstract _source.module path status)],
    } );
}

sub find {
  my ( $self, $distribution ) = @_;
  $self->request(
    '/release/_search',
    { query  => { match_all => {} },
      filter => {
        and => [
          { term => { 'release.distribution' => $distribution } },
          { term => { status                 => 'latest' } } ]
      },
      sort => [ { date => 'desc' } ],
      size => 1
    } );
}

sub root_files {
  my ( $self, $author, $release ) = @_;
  $self->request(
    '/file/_search',
    { query  => { match_all => {} },
      filter => {
        and => [
          { term => { release   => $release } },
          { term => { author    => $author } },
          { term => { level     => 0 } },
          { term => { directory => \0 } } ]
      },
      fields => [qw(name)],
      size   => 100,
    } );
}

sub versions {
  my ( $self, $dist ) = @_;
  $self->request(
    '/release/_search',
    { query  => { match_all => {} },
      filter => {
        and => [ { term => { 'release.distribution' => $dist } }, ],

      },
      size   => 100,
      sort   => [ { date => 'desc' } ],
      fields => [qw(name date author version)],
    } );
}

1;