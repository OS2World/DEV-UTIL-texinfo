#! /usr/local/bin/perl -w

# vim: tabstop=4
# vim: syntax=perl

use strict;

use Test;

BEGIN {
	plan tests => 7;
}

use Locale::Recode;

sub int2utf8;

my $local2ucs = {};
my $ucs2local = {};

while (<DATA>) {
	my ($code, $ucs, undef) = map { oct $_ } split /\s+/, $_;
	$local2ucs->{$code} = $ucs;
	$ucs2local->{$ucs} = $code unless $ucs == 0xfffd;
}

my $cd_int = Locale::Recode->new (from => 'ISO_2033-1983',
				  to => 'INTERNAL');
ok !$cd_int->getError;

my $cd_utf8 = Locale::Recode->new (from => 'ISO_2033-1983',
				   to => 'UTF-8');
ok !$cd_utf8->getError;

my $cd_rev = Locale::Recode->new (from => 'INTERNAL',
				  to => 'ISO_2033-1983');
ok !$cd_rev->getError;

# Convert into internal representation.
my $result_int = 1;
while (my ($code, $ucs) = each %$local2ucs) {
    my $outbuf = chr $code;
    my $result = $cd_int->recode ($outbuf);
    unless ($result && $outbuf->[0] == $ucs) {
	$result_int = 0;
	last;
    }
}
ok $result_int;

# Convert to UTF-8.
my $result_utf8 = 1;
while (my ($code, $ucs) = each %$local2ucs) {
    my $outbuf = chr $code;
    my $result = $cd_utf8->recode ($outbuf);
    unless ($result && $outbuf eq int2utf8 $ucs) {
        $result_utf8 = 0;
        last;
    }
}
ok $result_utf8;

# Convert from internal representation.
my $result_rev = 1;
while (my ($ucs, $code) = each %$ucs2local) {
    my $outbuf = [ $ucs ];
    my $result = $cd_rev->recode ($outbuf);
    unless ($result && $code == ord $outbuf) {
        $result_int = 0;
        last;
    }
}
ok $result_int;

# Check handling of unknown characters.
my $test_string1 = [ unpack 'c*', ' Supergirl ' ];
$test_string1->[0] = 0xad0be;
$test_string1->[-1] = 0xbeefbabe;
my $test_string2 = [ unpack 'c*', 'Supergirl' ];

my $unknown = "\x3f"; # Unknown character!

$cd_rev = Locale::Recode->new (from => 'INTERNAL',
		               to => 'ISO_2033-1983',
				)
&& $cd_rev->recode ($test_string1)
&& $cd_rev->recode ($test_string2)
&& ($test_string2 = $unknown . $test_string2 . $unknown);

ok $test_string1 eq $test_string2;

sub int2utf8
{
    my $ucs4 = shift;
    
    if ($ucs4 <= 0x7f) {
	return chr $ucs4;
    } elsif ($ucs4 <= 0x7ff) {
	return pack ("C2", 
		     (0xc0 | (($ucs4 >> 6) & 0x1f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0xffff) {
	return pack ("C3", 
		     (0xe0 | (($ucs4 >> 12) & 0xf)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0x1fffff) {
	return pack ("C4", 
		     (0xf0 | (($ucs4 >> 18) & 0x7)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0x3ffffff) {
	return pack ("C5", 
		     (0xf0 | (($ucs4 >> 24) & 0x3)),
		     (0x80 | (($ucs4 >> 18) & 0x3f)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } else {
	return pack ("C6", 
		     (0xf0 | (($ucs4 >> 30) & 0x3)),
		     (0x80 | (($ucs4 >> 24) & 0x1)),
		     (0x80 | (($ucs4 >> 18) & 0x3f)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    }
}

#Local Variables:
#mode: perl
#perl-indent-level: 4
#perl-continued-statement-offset: 4
#perl-continued-brace-offset: 0
#perl-brace-offset: -4
#perl-brace-imaginary-offset: 0
#perl-label-offset: -4
#tab-width: 4
#End:


__DATA__
0x00	0x0000
0x01	0x0001
0x02	0x0002
0x03	0x0003
0x04	0x0004
0x05	0x0005
0x06	0x0006
0x07	0x0007
0x08	0x0008
0x09	0x0009
0x0a	0x000a
0x0b	0x000b
0x0c	0x000c
0x0d	0x000d
0x0e	0x000e
0x0f	0x000f
0x10	0x0010
0x11	0x0011
0x12	0x0012
0x13	0x0013
0x14	0x0014
0x15	0x0015
0x16	0x0016
0x17	0x0017
0x18	0x0018
0x19	0x0019
0x1a	0x001a
0x1b	0x001b
0x1c	0x001c
0x1d	0x001d
0x1e	0x001e
0x1f	0x001f
0x20	0x0020
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0xfffd
0x30	0x0030
0x31	0x0031
0x32	0x0032
0x33	0x0033
0x34	0x0034
0x35	0x0035
0x36	0x0036
0x37	0x0037
0x38	0x0038
0x39	0x0039
0x3a	0x2446
0x3b	0x2447
0x3c	0x2448
0x3d	0x2449
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0xfffd
0x7f	0x007f
0x80	0xfffd
0x81	0xfffd
0x82	0xfffd
0x83	0xfffd
0x84	0xfffd
0x85	0xfffd
0x86	0xfffd
0x87	0xfffd
0x88	0xfffd
0x89	0xfffd
0x8a	0xfffd
0x8b	0xfffd
0x8c	0xfffd
0x8d	0xfffd
0x8e	0xfffd
0x8f	0xfffd
0x90	0xfffd
0x91	0xfffd
0x92	0xfffd
0x93	0xfffd
0x94	0xfffd
0x95	0xfffd
0x96	0xfffd
0x97	0xfffd
0x98	0xfffd
0x99	0xfffd
0x9a	0xfffd
0x9b	0xfffd
0x9c	0xfffd
0x9d	0xfffd
0x9e	0xfffd
0x9f	0xfffd
0xa0	0xfffd
0xa1	0xfffd
0xa2	0xfffd
0xa3	0xfffd
0xa4	0xfffd
0xa5	0xfffd
0xa6	0xfffd
0xa7	0xfffd
0xa8	0xfffd
0xa9	0xfffd
0xaa	0xfffd
0xab	0xfffd
0xac	0xfffd
0xad	0xfffd
0xae	0xfffd
0xaf	0xfffd
0xb0	0xfffd
0xb1	0xfffd
0xb2	0xfffd
0xb3	0xfffd
0xb4	0xfffd
0xb5	0xfffd
0xb6	0xfffd
0xb7	0xfffd
0xb8	0xfffd
0xb9	0xfffd
0xba	0xfffd
0xbb	0xfffd
0xbc	0xfffd
0xbd	0xfffd
0xbe	0xfffd
0xbf	0xfffd
0xc0	0xfffd
0xc1	0xfffd
0xc2	0xfffd
0xc3	0xfffd
0xc4	0xfffd
0xc5	0xfffd
0xc6	0xfffd
0xc7	0xfffd
0xc8	0xfffd
0xc9	0xfffd
0xca	0xfffd
0xcb	0xfffd
0xcc	0xfffd
0xcd	0xfffd
0xce	0xfffd
0xcf	0xfffd
0xd0	0xfffd
0xd1	0xfffd
0xd2	0xfffd
0xd3	0xfffd
0xd4	0xfffd
0xd5	0xfffd
0xd6	0xfffd
0xd7	0xfffd
0xd8	0xfffd
0xd9	0xfffd
0xda	0xfffd
0xdb	0xfffd
0xdc	0xfffd
0xdd	0xfffd
0xde	0xfffd
0xdf	0xfffd
0xe0	0xfffd
0xe1	0xfffd
0xe2	0xfffd
0xe3	0xfffd
0xe4	0xfffd
0xe5	0xfffd
0xe6	0xfffd
0xe7	0xfffd
0xe8	0xfffd
0xe9	0xfffd
0xea	0xfffd
0xeb	0xfffd
0xec	0xfffd
0xed	0xfffd
0xee	0xfffd
0xef	0xfffd
0xf0	0xfffd
0xf1	0xfffd
0xf2	0xfffd
0xf3	0xfffd
0xf4	0xfffd
0xf5	0xfffd
0xf6	0xfffd
0xf7	0xfffd
0xf8	0xfffd
0xf9	0xfffd
0xfa	0xfffd
0xfb	0xfffd
0xfc	0xfffd
0xfd	0xfffd
0xfe	0xfffd
0xff	0xfffd
