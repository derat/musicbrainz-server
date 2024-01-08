package MusicBrainz::Server::Translation::Instruments;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Translation';
with 'MusicBrainz::Server::Role::Translation' => { domain => 'instruments' };

sub l { __PACKAGE__->instance->gettext(@_) }
sub lp { __PACKAGE__->instance->pgettext(@_) }
sub ln { __PACKAGE__->instance->ngettext(@_) }

1;
