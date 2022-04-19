package MusicBrainz::Server::Report::ArtistsThatMayBePersons;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    q{
WITH groups_entity0 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('subgroup')),
     groups_entity1 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('member of band', 'collaboration', 'conductor position', 'artistic director', 'composer-in-residence', 'subgroup')),
     persons_entity0 AS (
         SELECT artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('member of band', 'supporting musician', 'collaboration', 'voice actor', 'conductor position', 'artistic director', 'composer-in-residence', 'teacher', 'is person', 'married', 'sibling', 'parent', 'involved with')),
     persons_entity1 AS (
         SELECT artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('teacher', 'catalogued', 'is person', 'married', 'sibling', 'parent', 'involved with')),
     artists AS (
         SELECT id, name FROM
             (SELECT * FROM persons_entity0
                  UNION
              SELECT * FROM persons_entity1) AS persons
          EXCEPT
              SELECT * FROM 
                (SELECT * FROM groups_entity0
                  UNION
                 SELECT * FROM groups_entity1) AS groups
     )
SELECT artists.id AS artist_id, row_number() OVER (ORDER BY artists.name COLLATE musicbrainz, artists.id)
    FROM artists
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
