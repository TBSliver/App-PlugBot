use strict;
use warnings;

my $socket_path = $ARGV[0] || 'plugbot.sock';

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use App::PlugBot;

my $bot = App::PlugBot->new( sockpath => $socket_path );

$bot->run;
