use strict;
use warnings;
use Test::More qw/no_plan/;

use BitIO;
use IO::String;

{
    my $h = IO::String->new;
    $h->print(pack('C', 1));
    $h->print(pack('C', 127));
    $h->seek(0, 0);

    my $b = BitIO->new($h);
    is $b->getc, 1;
    is $b->getc, 127;
    is $b->getc, undef;
}

{
    my $h = IO::String->new;
    $h->print(pack('C', 1));
    $h->print(pack('C', 126));
    $h->seek(0, 0);

    my $b = BitIO->new($h);
    ## 1 = 0000 0001
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 0;
    is $b->getbit, 1;

    ## 126 = 0111 1110
    is $b->getbit, 0;
    is $b->getbit, 1;
    is $b->getbit, 1;
    is $b->getbit, 1;
    is $b->getbit, 1;
    is $b->getbit, 1;
    is $b->getbit, 1;
    is $b->getbit, 0;

    is $b->getbit, undef;
}

{
    my $h = IO::String->new;
    $h->print(pack('C', 1));
    $h->print(pack('C', 126));
    $h->seek(0, 0);

    my $b = BitIO->new($h);
    is $b->getbits(8), 1;

    ## 0111 1110
    is $b->getbits(3), 3, 'getbits: 011';
    is $b->getbits(1), 1, 'getbits:    1';
    is $b->getbits(2), 3, 'getbits:      11';
    is $b->getbits(3), 4, 'getbits:        10';
    is $b->getbits(2), 0;
}
