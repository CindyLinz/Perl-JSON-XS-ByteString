# NAME

JSON::XS::ByteString - A more predictable and convenient XS implementation for JSON

# SYNOPSIS

    use JSON::XS::ByteString qw(encode_json encode_json_unblessed decode_json decode_json_safe);

    $json_string = encode_json($perl_data);
    $json_string_pretty = encode_json_pretty($perl_data);
    $perl_data = decode_json($json_string);
    $perl_data = decode_json($json_string, 1); # die if $json_string is not valid JSON string

    $json_string = encode_json_unblessed($perl_data);
    $json_string_pretty = encode_json_unblessed_pretty($perl_data);
        # the same behavior as encode_json
        #  but encode blessed references as reference strings,
        #  like 'Object=HASH(0xffffffff)'

# DESCRIPTION

This module is a XS implementation for JSON. It provide a more predictable behavior than [JSON::XS](https://metacpan.org/pod/JSON%3A%3AXS) by always producing strings in JSON for normal scalars.
And you can force it to produce numbers in JSON by putting references to numbers.

All the string data are treated as UTF-8 octets and just copy them in and out directly, except `"`, `\` and characters that `ord($char) < 32`

`decode_json` will return an undef without exceptions with invalid json string.

# DESIGN CONSIDERATION

## I didn't transfer the numeric value from `json_decode` back to string values

Because in the pure Perl world, there's insignificant difference between numeric or string.
So I think we don't need to do it since the result will be used in Perl.

## I didn't transfer the numeric value from `json_decode` back to reference values

Let `json_decode` preserve the identical structure as it received.

# FUNCTIONS

## $json\_string = encode\_json($perl\_data) / encode\_json\_pretty($perl\_data)

Get a JSON string from a perl data structure. Treat blessed objects as normal references.

## $json\_string = encode\_json\_unblessed($perl\_data) / encode\_json\_unblessed\_pretty($perl\_data)

Get a JSON string from a perl data structure. Treat blessed objects as strings (such as `'Object=HASH(0xffffffff)'`)

## $perl\_data = decode\_json($json\_string, $warn2die=0)

Get the perl data structure back from a JSON string.

If the given string is not a valid JSON string, it will return an `undef`.
If the `$warn2die` is false or not specified, this function will not die but warns an offset where it encountered the unrecognized character.
If the `$warn2die` is true, this function will die with the error message which is identical to the warning one.

## $perl\_data = decode\_json\_safe($json\_string)

The same as `decode_json` except that `decode_json_safe` will not warn at all.

# SEE ALSO

[JSON::XS](https://metacpan.org/pod/JSON%3A%3AXS)

This mod's github repository [https://github.com/CindyLinz/Perl-JSON-XS-ByteString](https://github.com/CindyLinz/Perl-JSON-XS-ByteString)

# AUTHOR

Cindy Wang (CindyLinz)

# COPYRIGHT AND LICENSE

Copyright (C) 2014-2021 by Cindy Wang (CindyLinz)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.
