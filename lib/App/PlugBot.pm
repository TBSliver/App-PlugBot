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
          on_json   => sub { $self->_incoming_ctrl( @_ ) },
          on_closed => sub { delete $self->ctrlsocks->{$_[0]} },
        );
        $acc_self->add_child( $stream );

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
  my ( $self, $jsonstream, $msg ) = @_;

  if ( $msg->{ 'cmd' } eq 'watch' ) {
    $jsonstream->{ 'watches' }{ $msg->{ 'args' } }++;
    $jsonstream->write_json( { 'status' => 'ok' } );
  } elsif ( $msg->{ 'cmd' } eq 'unwatch' ) {
    $jsonstream->{ 'watches' }{ $msg->{ 'args' } }--;
    $jsonstream->write_json( { 'status' => 'ok' } );
  } else {
    $self->send_to_listening( $msg );
  }
}

sub send_to_listening {
  my ( $self, $msg ) = @_;

  for my $ctrl ( values %{ $self->ctrlsocks } ) {
    $ctrl->write_json( { %$msg } ) if $ctrl->{watches}{ $msg->{ 'cmd' } };
  }
};

1;
