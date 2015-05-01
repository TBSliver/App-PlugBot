use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use App::PlugBot;

my $bot = App::PlugBot->new;

$bot->run;
