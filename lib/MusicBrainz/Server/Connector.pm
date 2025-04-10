package MusicBrainz::Server::Connector;
use Moose;
use MusicBrainz::Server::Exceptions;
use DBIx::Connector;
use Sql;
use Encode qw( decode_utf8 );

has 'conn' => (
    isa        => 'DBIx::Connector',
    is         => 'ro',
    handles    => [qw( dbh )],
    lazy_build => 1,
    clearer => '_clear_conn',
    predicate => 'has_conn',
);

has 'database' => (
    isa => 'MusicBrainz::Server::Database',
    is  => 'rw',
);

has 'sql' => (
    is => 'ro',
    default => sub {
        my $self = shift;
        my $sql = Sql->new( $self->conn );
        $sql->read_only($self->read_only);
        return $sql;
    },
    lazy => 1,
    clearer => '_clear_sql',
);

has 'read_only' => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

sub _build_conn
{
    my ($self) = @_;

    my $dsn = 'dbi:Pg:dbname=' . $self->database->database;
    $dsn .= ';host=' . $self->database->host if $self->database->host;
    $dsn .= ';port=' . $self->database->port if $self->database->port;

    my $db = $self->database;
    my $conn = DBIx::Connector->new($dsn, $db->username, $db->password, {
        # Prepared statements are not shared across database connections,
        # meaning they won't work alongside pgbouncer.
        pg_server_prepare => 0,
        HandleError       => sub {
            my ($msg, $h) = @_;
            my $state = $h->state;
            my $exception = 'MusicBrainz::Server::Exceptions::DatabaseError';
            $exception .= '::StatementTimedOut'
                if $state eq '57014';
            # Sometimes we receive a byte string that doesn't have the UTF8
            # flag set; other times it's already been decoded (MBS-11207).
            $msg = decode_utf8($msg)
                unless utf8::is_utf8($msg);
            $exception->throw( sqlstate => $state, message => $msg );
        },
        RaiseError        => 0,
        PrintError        => 0,
        ShowErrorStatement => 1,
    });

    # Make sure we notice the DB going down and attempt to reconnect
    $conn->mode('fixup');

    return $conn;
}

sub _disconnect {
    my ($self) = @_;
    if ($self->has_conn) {
        $self->conn->disconnect;
    }

    $self->_clear_conn;
    $self->_clear_sql;
}

sub disconnect {
    my $self = shift;
    $self->_disconnect;
}

sub refresh {
    my $self = shift;
    $self->disconnect;
    # A connection will be established on demand
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
