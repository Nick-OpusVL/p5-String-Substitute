package String::Substitute;

our $VERSION = '0.001';

use Exporter::Easy (
    OK => [qw/get_all_substitutes/],
);
use Regexp::Genex;
use List::Gather;
use Data::Munge qw(elem);
use Params::Validate qw(:all);
use strictures 2;
use namespace::clean;

sub get_all_substitutes {
    my %params = validate(
        @_, {
            string => { type => SCALAR },
            substitutions => { type => HASHREF },
        }
    );


    my @results;
    push @results, $params{string};

    my %subs = %{$params{substitutions}};
    my @substitutable_chars = keys %subs;

    # Build a regex for Regexp::Genex.
    my @regex_parts = gather {
        my @chars = split //, $params{string};
        for my $char (@chars) {
            if (elem $char => \@substitutable_chars) {
                my @char_possible_subs = split(//, $subs{$char});
                my @quoted_literals = map { quotemeta($_) } @char_possible_subs;
                # Build an alternatives group, e.g. (A|B|C), from @quoted_literals
                take sprintf("(%s)", join('|', @quoted_literals));
            }
            else {
                take quotemeta($char);
            }
        }
    };
    my $regex = join '', @regex_parts;

    # NOTE: Regexp::Genex admits to relying on experimental features and avoiding optimizations in the regex engine.
    #       Therefore care should be taken if upgrading the Perl interpreter - make sure you run the tests!
    return Regexp::Genex::strings($regex);
}


1;

# ABSTRACT: generate strings using different combinations of subsitute characters

=head1 NAME

String::Substitute - generate strings using different combinations of subsitute characters

=head1 SYNOPSIS

    use String::Substitute qw(get_all_substitutes);

    my @results = get_all_substitutes(
        string => 'ABC',
        substitutions => {
            A => 'Aa',
            B => 'Bb',
        },
    );

    say for @results;

would print

    ABC
    aBC
    AbC
    abC

As a one-liner it might look like this:

    perl -Ilib -MString::Substitute=get_all_substitutes -E 'say for get_all_substitutes(string => "ABC", substitutions => { A => "Aa", B => "Bb" })'

=head1 STABILITY

Experimental, mostly because this depends on L<Regex::Genex> which itself admits to relying on experimental or changeable
aspects of the Perl interpreter.

Tested on perl 5.20.3 - be sure to run the tests on newer versions if you will be relying on this

=head1 SUPPORT

If you require assistance, support, or further development of this software, please contact OpusVL using the details below:

Telephone: +44 (0)1788 298 410

Email: community@opusvl.com

Web: http://opusvl.com

=head1 COPYRIGHT & LICENSE

Copyright (C) 2017 Opus Vision Limited

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself.

=cut
