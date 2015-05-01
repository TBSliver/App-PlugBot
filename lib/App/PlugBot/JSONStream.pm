package App::PlugBot::JSONStream;
use base qw( IO::Async::Stream );
use JSON::MaybeXS;

sub configure {
  my $self = shift;
  my %args = @_;

  foreach (qw( on_json )) {
    $self->{$_} = delete $args{$_} if exists $args{$_};
  }

  $self->SUPER::configure( %args );
}

sub on_read {
  my $self = shift;
  my ( $buffref, $eof ) = @_;
  return if $eof;

  while( $$buffref =~ s/^(.*)\n// ) {
    $self->invoke_event( on_json => decode_json( $1 ) );
  }

  return 0;
}

sub write_json {
  my $self = shift;
  my ( $data ) = @_;
  $self->write( encode_json( $data ) . "\n" );
}

1;
