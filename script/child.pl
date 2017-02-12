use strict;
use warnings;

my $socket_path = $ARGV[0] || 'plugbot.sock';

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use IO::Async::Loop;
use App::PlugBot::JSONStream;
use Data::Dumper;

my $loop = IO::Async::Loop->new;

my $stream = App::PlugBot::JSONStream->new(
  plugbot_socket => $socket_path,
  on_json => sub {
    my ( $self, $data ) = @_;
    print Dumper $data;
  },
);
 
$loop->add( $stream );
 
$stream->watch('text');
$stream->transmit('text', {beep => 'boop'});

$loop->run;
