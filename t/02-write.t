use strict;
use warnings;
use Test::More qw/no_plan/;

use BitIO;
use IO::String;

{
    my $h = IO::String->new;

    my $b = BitIO->new($h);
    $b->putc(1);
    $b->putc(127);
    $b->rewind;
    is $b->getc, 1;
    is $b->getc, 127;
}

{
    my $h = IO::String->new;
    my $b = BitIO->new($h);

    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(0);
    $b->putbit(1);

    $b->putbit(0);
    $b->putbit(1);
    $b->putbit(1);
    $b->putbit(1);
    $b->putbit(1);
    $b->putbit(1);
    $b->putbit(1);
    $b->putbit(0);

    $b->rewind;
    is $b->getc, 1;
    is $b->getc, 126;

    is $b->getc, undef;
}

{
    my $h = IO::String->new;
    my $b = BitIO->new($h);
    $b->putbits(8, 1);
    $b->putbits(8, 126);
    $b->rewind;
    is $b->getc, 1;
    is $b->getc, 126;
    is $b->getc, undef;

    $b->putbit(1);
    $b->close;
    $h->seek(0, 0);
    is $b->getc, 1;
}
