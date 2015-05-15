package Mailbot;

use 5.010;

use Moo;
use Mail::IMAPClient;
use MIME::Parser;
use URI::Find;
use LWP::UserAgent;

our $VERSION = '0.0.1';

has user        => ( is => 'rw' );
has pw          => ( is => 'rw' );
has server      => ( is => 'rw' );
has ssl         => ( is => 'rw' );
has port        => ( is => 'rw' );
has imap        => ( is => 'rw' );
has ua          => ( is => 'rw' );
has parser      => ( is => 'rw' );
has finder      => ( is => 'rw' );
has url         => ( is => 'rw' );
has allowedFrom => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_init_imap();
    $self->_init_parser();
    $self->_init_ua();
    $self->_init_finder();
}

sub process {
    my $self = shift;
    if ( $self->imap->unseen_count == 0 ) {
        return;
    }
    my @unread = $self->imap->unseen() or die $@;
    foreach my $uid (@unread) {
        my $entity = $self->parser->parse_data(
            $self->imap->message_string($uid)
        );
        my $header = $entity->head;
        my $from   = $header->get_all("From");
        if ( $from !~ /$self->{allowedFrom}/ ) {
            next;
        }
        my $content = $self->_split_entity($entity);
        $self->finder->find( \$content );
        my $response = $self->ua->get( $self->{url} );
        if ( $response->is_success ) {
            say $response->decoded_content;
        }
    }
    $self->imap->logout;
}

sub _init_imap {
    my $self = shift;
    $self->imap(
        Mail::IMAPClient->new(
            User     => $self->{user},
            Password => $self->{pw},
            Server   => $self->{server},
            Ssl      => $self->{ssl},
            Port     => $self->{port},
        ) );    # or die "while creating imap client $@";
    $self->imap->select('INBOX');
}

sub _init_parser {
    my $self   = shift;
    my $parser = MIME::Parser->new;
    $parser->output_dir("/tmp");
    $parser->tmp_dir("/tmp");
    $self->parser($parser);
}

sub _init_ua {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    $self->ua($ua);
}

sub _init_finder {
    my $self   = shift;
    my $finder = URI::Find->new(
        sub {
            my $uri = shift;
            if ( $uri =~ /https\S+csv$/ ) {
                $self->url($uri);
            }
          }
    );
    $self->finder($finder);
}

sub _split_entity
{
    my $self      = shift;
    my $entity    = shift;
    my $result    = '';
    my $num_parts = $entity->parts;
    if ($num_parts) {
        foreach ( 1 .. $num_parts ) {
            $result .= $self->_split_entity( $entity->parts( $_ - 1 ) );
        }
    } else {
        return $entity->bodyhandle->as_string;
    }
    return $result;
}

1;
