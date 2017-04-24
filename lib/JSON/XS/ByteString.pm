package JSON::XS::ByteString;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(encode_json encode_json_unblessed decode_json decode_json_safe);
our $VERSION = 1.000000;

require XSLoader;
XSLoader::load('JSON::XS::ByteString', $VERSION);

=head1 NAME

JSON::XS::ByteString - Thin wrapper around fast L<JSON::XS> that makes each JSON fields as string, and Perl fields as bytes (utf8 octet)

=head1 SYNOPSIS

    use JSON::XS::ByteString qw(encode_json encode_json_unblessed decode_json decode_json_safe encode_utf8 decode_utf8 encode_utf8_unblessed decode_utf8_unblessed);

    $json_string = encode_json($perl_data);
    $perl_data = decode_json($json_string);
    $perl_data = decode_json_safe($json_string);

    $json_string = encode_json_unblessed($perl_data);
        # the same behavior as encode_json
        #  but encode blessed references as reference strings,
        #  like 'Object=HASH(0xffffffff)'

    # low-level tool, I don't use them directly.
    #  But if your situation is not exactly the same as mine,
    #  you might use them directly to fit your own situation.
    encode_utf8($perl_data);
        # no return value. downgrade each string field into utf8 encoded octet
    decode_utf8($perl_data);
        # no return value. upgrade each string and numeric field into multibyte chars,

    encode_utf8_unblessed($perl_data);
    decode_utf8_unblessed($perl_data);
        # the same as encode_utf8 and decode_utf8,
        #  but leaves blessed references untouched

=head1 DESCRIPTION

This module is a wrapper around L<JSON::XS> for making the life easier dealing with UTF-8 byte strings.

The added overhead is very low, you can try that your self ^^

The module try to achieve that by 3 approaches below:

=over 4

=item *
Transfer all the non-ref, non-undef values into strings before building the JSON string from Perl data

Because by the Perl nature, it's hard to determine if the outputted one is a string or numeric one.
The nondeterministic will make the life harder if the acceptor is writing in other languages
that strictly care about if it's string or number.

=item *
[EXPERIMENTAL] Transfer all the scalar-ref values into number of its referred values.

Since the scalar reference is not valid in a JSON structure, we use this form as a stable numeric hint
that will not be changed by how you use the value last time (the JSON::XS' nature).

Note that C<decode_json> will not do the inverse. It will leave the number value be still a number value,
not a reference to a number value.

=item *
Transfer all the utf8 encoded octet into multibyte-char strings before encoding to JSON string.
If there're any malform octets, we'll transfer those bytes into questionmarks(?).

If your situation is just like me that we all use utf8 encoded octet all around,
it's cumbersome and slow that we need to recursively upgrade all the string value into multibyte chars
before C<JSON::XS::encode_json>.

=item *
Transfer all the multibyte-char strings into utf8 encoded octet after decoding JSON string
to Perl data.

If your situation is just like me that we all use utf8 encoded octet all around,
it's cumbersome and slow that we need to recursively downgrade all the string value back to utf8 encoded octet
after C<JSON::XS::decode_json>.

=back

=head1 DESIGN CONSIDERATION

=head2 I didn't transfer the numeric value from C<json_decode> back to string values

Because in the pure Perl world, there's insignificant difference between numeric or string.
So I think we don't need to do it since the result will be used in Perl.

=head2 I didn't transfer the numeric value from C<json_decode> back to reference values

Let C<json_decode> preserve the identical structure as it received.

=head1 FUNCTIONS

=head2 $json_string = encode_json($perl_data)
=head2 $json_string = encode_json_unblessed($perl_data)

Get a JSON string from a perl data structure.

Before calling to JSON::XS::encode_json. This function will transfer (modify the input data directly)

=over 4

=item * each non-string, non-arrayref, non-hashref scalar into multibyte-char string value

=item * each whole bytes (utf8-octet) into multibyte-char string value. when there're any malform octets, transfer them to questionmarks(?).

=back

After that, the function will then transfer

=over 4

=item * each multibyte-char string back to bytes (utf8-octet)

=item * each questionmark back to original malform octets

=back

JSON::XS::encode_json_unblessed will encode blessed references to
reference string (something like Object=HASH(0xffffffff))

=cut

=head2 $perl_data = decode_json($json_string)

Get the perl data structure back from a JSON string.

After the call to JSON::XS::decode_json, the function
will transfer each multibyte-char string field into bytes (utf8-octet)

Note that only the string values are converted, the numeric ones are not.

=cut

=head2 $perl_data = decode_json_safe($json_string)

The same as C<decode_json>

This function is only for convenience.

=cut
*decode_json_safe = \&JSON::XS::ByteString::decode_json;

=head1 CAVEATS

=head1 SEE ALSO

L<JSON::XS>

This mod's github repository L<https://github.com/CindyLinz/Perl-JSON-XS-ByteString>

=head1 AUTHOR

Cindy Wang (CindyLinz)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Cindy Wang (CindyLinz)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
