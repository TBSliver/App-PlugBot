use strict;
use warnings;

my $socket_path = $ARGV[0] || 'plugbot.sock';

use IO::Async::Stream;
use IO::Async::Loop;
use IO::Socket::UNIX;

my $loop = IO::Async::Loop->new;

my $socket = IO::Socket::UNIX->new(
  Peer => $socket_path,
) or die "Cannot make UNIX socket - $!\n"; 

my $stream = IO::Async::Stream->new(
  handle => $socket,
 
  on_read => sub {
    my ( $self, $buffref, $eof ) = @_;

    while( $$buffref =~ s/^(.*\n)// ) {
      print "Received a line $1";
    }

    if( $eof ) {
      print "EOF; last partial line is $$buffref\n";
    }

    return 0;
  }
);
 
$loop->add( $stream );
 
$stream->write( '{"cmd":"watch","args":"text"}' . "\n" );
$stream->write( '{"cmd":"text","beep":"boop"}' . "\n" );

$loop->run;
