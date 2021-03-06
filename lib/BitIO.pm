package BitIO;
use strict;
use warnings;

our $VERSION = '0.01';

use Params::Validate qw/validate_pos HANDLE/;

use constant HANDLER => 0;
use constant BUFF    => 1;
use constant GETCNT  => 2;
use constant PUTCNT  => 3;

sub new {
    my ($class, $handler) = validate_pos(@_, 1, { type => HANDLE });
    my $self = bless [], $class;

    $self->[HANDLER] = $handler;
    $self->[BUFF]    = 0;
    $self->[GETCNT]  = 0;
    $self->[PUTCNT]  = 8;

    return $self;
}

sub getc {
    my $self = shift;
    my $c = $self->[HANDLER]->getc;
    if (defined $c) {
        return unpack('C', $c);
    }
    return;
}

sub getbit {
    my $self = shift;
    $self->[GETCNT]--;
    if ($self->[GETCNT] < 0) {
        $self->[BUFF] = $self->getc;
        if (not defined $self->[BUFF]) {
            return;
        }
        $self->[GETCNT] = 7;
    }
    return ($self->[BUFF] >> $self->[GETCNT]) & 1;
}

sub rightbits {
    my ($n, $x) = @_;
    return ($x & ((1 << $n) - 1));
}

# sub getbits {
#     my ($self, $n) = @_;
#     my $v = 0;
#     my $p = 1 << ($n - 1);
#     while ($p > 0) {
#         my $bit = $self->getbit;
#         if ($bit and $bit == 1) {
#             $v |= $p;
#         }
#         $p >>= 1;
#     }
#     return $v;
# }

sub getbits {
    my ($self, $n) = @_;
    my $v = 0;
    while ($n > $self->[GETCNT]) {
        $n -= $self->[GETCNT];
        $v |= ($self->[BUFF] & ((1 << $self->[GETCNT]) - 1)) << $n;
        $self->[BUFF] = $self->getc;
        $self->[GETCNT] = 8;
    }

    $self->[GETCNT] -= $n;

    if (not defined $self->[BUFF]) {
        return $v;
    }

    return $v | (($self->[BUFF] >> $self->[GETCNT]) & ((1 << $n) - 1));
}

sub putc {
    my ($self, $c) = @_;
    $self->[HANDLER]->write(pack('C', $c), 1);
}

sub putbit {
    my ($self, $bit) = @_;
    $self->[PUTCNT]--;
    if ($bit > 0) {
        $self->[BUFF] |= (1 << $self->[PUTCNT]);
    }

    if ($self->[PUTCNT] == 0) {
        $self->putc($self->[BUFF]);
        $self->[BUFF] = 0;
        $self->[PUTCNT] = 8;
    }
}

sub putbits {
    my ($self, $n, $v) = @_;
    while ($n >= $self->[PUTCNT]) {
        $n -= $self->[PUTCNT];
        $self->[BUFF] |= (($v >> $n) & ((1 << $self->[PUTCNT]) - 1));
        $self->putc($self->[BUFF]);
        $self->[BUFF]   = 0;
        $self->[PUTCNT] = 8;
    }
    $self->[PUTCNT] -= $n;
    $self->[BUFF] |= ($v & ((1 << $n) - 1)) << $self->[PUTCNT];
}

sub rewind {
    my $self = shift;
    $self->[HANDLER]->seek(0, 0);
}

sub write {
    my ($self, $v) = @_;
    $self->[HANDLER]->print($v);
}

sub read {
    my ($self, $r_buff, $len) = @_;
    $self->[HANDLER]->read($$r_buff, $len);
}

sub flush {
    my $self = shift;
    if ($self->[GETCNT] < 8) {
        $self->putc($self->[BUFF]);
    }
}

1;

__END__

=head1 NAME

BitIO - Bit Stream I/O

=head1 SYNOPSIS

  use BitIO;

  my $h = IO::String->new;
  my $w = BitIO->new($h);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(0);
  $w->putbit(1);
  $w->putbits(8, 126);
  $w->flush;

  $h->seek(0, 0);

  my $r = BitIO->new($h);
  is $r->getbits(8), 1;
  is $r->getbits(8), 126;

=head1 DESCRIPTION

Bit I/O Stream with an arbitrary I/O handle

=head1 SEE ALSO

L<http://www.geocities.jp/m_hiroi/light/pyalgo30.html> (in Japanese)

=head1 AUTHOR

Naoya Ito, E<lt>naoya at bloghackers.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Naoya Ito

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
