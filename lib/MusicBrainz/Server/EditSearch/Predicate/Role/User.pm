package MusicBrainz::Server::EditSearch::Predicate::Role::User;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $BEGINNER_FLAG );
use MusicBrainz::Server::Validation qw( is_database_row_id );

parameter template_clause => (
    isa => 'Str',
    required => 1,
);

role {
    my $params = shift;
    my $template_clause = $params->template_clause;

    with 'MusicBrainz::Server::EditSearch::Predicate::Role::Subscribed' => {
        type => 'editor',
        template_clause => "$template_clause",
        subscribed_column => 'subscribed_editor',
    };

    has name => (
        is => 'ro',
        isa => 'Str',
    );

    method operator_cardinality_map => sub {
        return (
            '=' => 1,
            '!=' => 1,
            'me' => 0,
            'not_me' => 0,
            'limited' => 0,
            'not_limited' => 0,
            'not_edit_author' => 0,
            'nobody' => 0,
        );
    };

    method combine_with_query => sub {
        my ($self, $query) = @_;

        my $sql = $template_clause =~ s/ROLE_CLAUSE\(([^)]*)\)/$1 = ?/r;

        if ($self->operator eq '!=' || $self->operator eq 'not_me') {
            $sql = 'NOT ' . $sql;
        }

        if ($self->operator eq 'me' || $self->operator eq 'not_me') {
            $query->add_where([ $sql, [ $self->user->id ] ]);
        } elsif ($self->operator eq 'limited') {
            my $beginner_sql = <<~'SQL';
                SELECT id
                  FROM editor beginner
                 WHERE (privs & ?) > 0
                SQL

            $sql = $template_clause =~
                s/ROLE_CLAUSE\(([^)]*)\)/$1 IN ($beginner_sql)/r;
            $query->add_where([ $sql, [ $BEGINNER_FLAG ] ]);
        } elsif ($self->operator eq 'not_limited') {
            my $nonbeginner_sql = <<~'SQL';
                SELECT id
                  FROM editor non_beginner
                 WHERE (privs & ?) = 0
                SQL

            $sql = $template_clause =~
                s/ROLE_CLAUSE\(([^)]*)\)/$1 IN ($nonbeginner_sql)/r;
            $query->add_where([ $sql, [ $BEGINNER_FLAG ] ]);
        } elsif ($self->operator eq 'not_edit_author') {
            $query->add_where([
                'EXISTS (
                    SELECT TRUE FROM edit_note
                        WHERE edit_note.edit = edit.id
                        AND edit_note.editor != edit.editor
                )',
                [ ],
            ]);
        } elsif ($self->operator eq 'nobody') {
            $sql = <<~'SQL';
                NOT EXISTS (
                    SELECT TRUE
                      FROM edit_note
                     WHERE edit_note.edit = edit.id
                )
                SQL
            $query->add_where([ $sql, [ ] ]);
        } else {
            $query->add_where([ $sql, [ $self->arguments ] ]);
        }
    };

    # We would probably want 'override' here but 'around' is needed
    # to work around method name conflicts
    around valid => sub {
        my ($orig, $self) = @_;

        return 1 unless $self->operator_cardinality($self->operator);
        my @args = $self->arguments;
        return scalar(@args) == 1 && is_database_row_id($args[0]);
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
