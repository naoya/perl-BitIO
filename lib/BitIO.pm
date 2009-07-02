package BitIO;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

our $VERSION = '0.01';

use Params::Validate qw/validate_pos HANDLE/;

__PACKAGE__->mk_accessors(qw/stream buff bitlen/);

sub new {
    my ($class, $handler) = validate_pos(@_, 1, { type => HANDLE });
    my $self = $class->SUPER::new;

    $self->stream = $handler;
    $self->buff    = 0;
    $self->bitlen = 0;

    return $self;
}

sub getc {
    my $self = shift;
    my $c = $self->stream->getc;
    if (defined $c) {
        return unpack('C', $c);
    }
    return;
}

sub getbit {
    my $self = shift;
    $self->bitlen--;
    if ($self->bitlen < 0) {
        $self->buff = $self->getc;
        if (not defined $self->buff) {
            return;
        }
        $self->bitlen = 7;
    }
    return ($self->buff >> $self->bitlen) & 1;
}

sub getbits {
    my ($self, $n) = @_;
    my $v = 0;
    my $p = 1 << ($n - 1);
    while ($p > 0) {
        my $bit = $self->getbit;
        if ($bit and $bit == 1) {
            $v |= $p;
        }
        $p >>= 1;
    }
    return $v;
}

sub putc {
    my ($self, $c) = @_;
    $self->stream->write(pack('C', $c), 1);
}

sub putbit {
    my ($self, $bit) = @_;
    $self->bitlen++;

    if ($bit > 0) {
        $self->buff |= (1 << 8 - $self->bitlen);
    }

    if ($self->bitlen == 8) {
        $self->putc($self->buff);
        $self->buff   = 0;
        $self->bitlen = 0;
    }
}

sub putbits {
    my ($self, $n, $v) = @_;
    if ($n > 0) {
        my $p = 1 << ($n - 1);
        while ($p > 0) {
            $self->putbit( $v & $p );
            $p >>= 1;
        }
    }
}

sub rewind {
    my $self = shift;
    $self->stream->seek(0, 0);
}

sub close {
    my $self = shift;
    if ($self->bitlen < 8) {
        $self->putc($self->buff);
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
