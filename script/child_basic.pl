use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

my $socket_path = $ARGV[0] || 'plugbot.sock';

use IO::Socket::UNIX;

my $clientsock = IO::Socket::UNIX->new(
  Peer => $socket_path,
) or die "Cannot make UNIX socket - $!\n";

$clientsock->send('{"cmd":"watch","args":"text"}' . "\n");

while ( ! eof($clientsock) ) {
  defined( $_ = readline $clientsock ) or die "readline failed: $!";
  print $_;
}
