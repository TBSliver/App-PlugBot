package App::PlugBot;

use strict;
use warnings;

use Moo;

use IO::Async::Loop;
use IO::Async::Listener;

use App::PlugBot::JSONStream;

has _loop => (
  is => 'lazy',
  default => sub {
    return IO::Async::Loop->new;
  }
);

has sockpath => (
  is => 'ro',
  default => 'plugbot.sock',
  coerce => sub {
    my $sock = shift;
    # remove socket if it exists
    unlink $sock if -S $sock;
    return $sock;
  },
);

has ctrlsocks => (
  is => 'rw',
  default => sub { {} },
);

has ctrlserver => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return IO::Async::Listener->new(
      handle_class => "App::PlugBot::JSONStream",
      on_accept => sub {
        my ( $acc_self, $stream ) = @_;

        $stream->configure(
          on_json   => \&_incoming_ctrl,
          on_closed => sub { delete $self->ctrlsocks->{$_[0]} },
        );
        $acc_self->add_child( $stream );

        ::Dwarn $stream;
        $self->ctrlsocks->{$stream} = $stream;
      },
    );
  }
);

sub run {
  my $self = shift;
  print "Running!\n";
  $self->_loop->add( $self->ctrlserver );
  $self->ctrlserver->listen(
    addr => { family => "unix", path => $self->sockpath },
  )->get;
  $self->_loop->run;
}

sub _incoming_ctrl {
  my ( $ctrlsock, $ctrl ) = @_;
  my ( $cmd, @args ) = @$ctrl;

  $| = 1;
  print "Recieved: $cmd - " . join( ' ', @args );
  $ctrlsock->write_json( { "cmd" => $cmd, "args" => join( ' ', @args) } );
}

1;
