#!/usr/bin/perl
#
# https://github.com/fbreitwieser
#
# apt-get install libfont-freetype-perl
#
# If you get a config where you get a "tofu" character instead of a proper glyph then
# run this script to known which fonts provide that glyph and compare that font name with your config.

use strict;
use warnings;
use Font::FreeType;
my ($char) = @ARGV;
foreach my $font_def (`fc-list`) {
    my ($file, $name) = split(/: /, $font_def);
    my $face = Font::FreeType->new->face($file);
    my $glyph = $face->glyph_from_char($char);
    if ($glyph) {
        print $font_def;
    }
}

