package App::PlugBot::JSONStream;

use base qw( IO::Async::Stream );
use JSON::MaybeXS;
use IO::Socket::UNIX;
use Try::Tiny;

sub configure {
  my $self = shift;
  my %args = @_;

  foreach (qw( on_json )) {
    $self->{$_} = delete $args{$_} if exists $args{$_};
  }

  if (exists $args{plugbot_socket} && ! exists $args{handle}) {
    $args{handle} = IO::Socket::UNIX->new(
      Peer => delete $args{plugbot_socket},
    ) or die "Cannot connect to UNIX socket - $!\n";
  }

  $self->SUPER::configure( %args );
}

sub on_read {
  my $self = shift;
  my ( $buffref, $eof ) = @_;
  return if $eof;

  while( $$buffref =~ s/^(.*)\n// ) {
    try {
      $self->invoke_event( on_json => decode_json( $1 ) );
    } catch {
      warn "Couldnt decode JSON - was it valid?: [$_]";
    }
  }

  return 0;
}

sub write_json {
  my $self = shift;
  my ( $data ) = @_;
  $self->write( encode_json( $data ) . "\n" );
}

sub watch {
  shift->write_json({ cmd => 'watch', args => shift });
}

sub unwatch {
  shift->write_json({ cmd => 'unwatch', args => shift });
}

sub transmit {
  shift->write_json({ cmd => shift, args => shift });
}

1;
