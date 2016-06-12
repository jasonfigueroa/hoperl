#!/usr/bin/perl

# Parsing the outline points for a list here.  Slightly different departure from regex and arithmetic.

use Lexer ':all';
use Stream 'node';

my ($tree, $subtree);
sub outline_to_array {
    my @input = @_;
    my $input = sub { shift @input };
    my $lexer = iterator_to_stream(make_lexer($input,
                                              ['ITEM', qr/^.*$/m], ['NEWLINE', qr/\n+/, sub { "" }],));
    my ($result) = $tree->($lexer);
    return $result;
}
use Parser ':all';
use Stream 'head';

my $Tree = parser { $tree->(@_) };
my $Subtree = parser { $subtree->(@_) };
my $LEVEL = 0;
$tree = concatenate(lookfor('ITEM', sub { trim($_[0][1]) }),
    action(sub { $LEVEL++ }),
    star($Subtree),
                    action(sub { $LEVEL-- }));

my $BULLET = '[#*ox.+-]\s+';
sub trim {
    my $s = shift;
    $s =~ s/^ *//;
    $s =~ s/^$BULLET//o;
    return $s;
}