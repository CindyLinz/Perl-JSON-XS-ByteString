# NAME

JSON::XS::ByteString - Thin wrapper around fast JSON::XS that makes each JSON fields as string, and Perl fields as bytes (utf8 octet)

# SYNOPSIS

```perl
    use JSON::XS::ByteString qw(encode_json encode_json_unblessed decode_json decode_json_safe encode_utf8 decode_utf8 encode_utf8_unblessed decode_utf8_unblessed);

    $json_string = encode_json($perl_data);
    $json_string = encode_json_unsafe($perl_data);
    $perl_data = decode_json($json_string);
    $perl_data = decode_json_safe($json_string);

    $json_string = encode_json_unblessed($perl_data);
    $json_string = encode_json_unblessed_unsafe($perl_data);
        # the same behavior as encode_json and encode_json_unsafe
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
```

# DESCRIPTION

This module is a wrapper around JSON::XS for making the life easier dealing with UTF-8 byte strings.

The added overhead is very low, you can try that your self ^^

The module try to achieve that by 3 approaches below:

- Transfer all the non-ref, non-undef values into strings before building the JSON string from Perl data

  Because by the Perl nature, it's hard to determine if the outputted one is a string or numeric one.
  The nondeterministic will make the life harder if the acceptor is writing in other languages
  that strictly care about if it's string or number.

- [EXPERIMENTAL] Transfer all the scalar-ref values into number of its referred values.

  Since the scalar reference is not valid in a JSON structure, we use this form as a stable number hint
  that will not be changed by how you use the value last time (the JSON::XS' nature).

  Note that C<decode_json> will not do the inverse. It will leave the number value be still a number value,
  not a reference to a number value.


- Transfer all the utf8 encoded octet into multibyte-char strings before encoding to JSON string.
  If there're any malform octets, we'll transfer those bytes into questionmarks(?).
  If you use the \_unsafe version, we'll just leave them there, otherwise we'll recover the questionmarks back
  to the original malform octets.

  If your situation is just like me that we all use utf8 encoded octet all around,
  it's cumbersome and slow that we need to recursively upgrade all the string value into multibyte chars
  before `JSON::XS::encode_json`.

- Transfer all the multibyte-char strings into utf8 encoded octet after decoding JSON string
to Perl data.

  If your situation is just like me that we all use utf8 encoded octet all around,
  it's cumbersome and slow that we need to recursively downgrade all the string value back to utf8 encoded octet
  after `JSON::XS::decode_json`.

# DESIGN CONSIDERATION

### I didn't transfer the numeric value from `json_decode` back to string values

Because in the pure Perl world, there's insignificant difference between numeric or string.
So I think we don't need to do it since the result will be used in Perl.

### I didn't transfer the numeric value from `json_decode` back to reference values

Let `json_decode` preserve the identical structure as it received.


# FUNCTIONS

### $json\_string = encode\_json($perl\_data)
### $json\_string = encode\_json\_unblessed($perl\_data)

Get a JSON string from a perl data structure.

Before calling to JSON::XS::encode\_json. This function will transfer (modify the input data directly)

- each non-string, non-arrayref, non-hashref scalar into multibyte-char string value
- each whole bytes (utf8-octet) into multibyte-char string value. when there're any malform octets, transfer them to questionmarks(?).

After that, the function will then transfer

- each multibyte-char string back to bytes (utf8-octet)
- each questionmark back to original malform octets

JSON::XS::encode\_json\_unblessed will encode blessed references to
reference string (something like Object=HASH(0xffffffff))

### $json\_string = encode\_json\_unsafe($perl\_value)
### $json\_string = encode\_json\_unblessed\_unsafe($perl\_value)

Same as `encode_json` except the last step after `JSON::XS::encode_json`.
The argument will be upgraded to multibyte chars and never back.

If there are any scalar reference as numeric hints,
they will become numeric values.

This function is a little faster than the `encode_json`.
Use it if you're sure that you'll not use the argument after the JSON call.

JSON::XS::encode\_json\_unblessed\_unsafe will encode blessed references
to reference string (something like Object=HASH(0xffffffff))

### $perl\_data = decode\_json($json\_string)

Get the perl data structure back from a JSON string.

After the call to JSON::XS::decode\_json, the function
will transfer each multibyte-char string field into bytes (utf8-octet)

Note that only the string values are converted, the numeric ones are not.

### $perl\_data = decode\_json\_safe($json\_string)

The same as `decode_json` but wrap it around an `eval` block and suppress
the `$SIG{__DIE__}` signal.
We'll get an `undef` value back when decode fail.

This function is only for convenience.

### encode\_utf8($perl\_data)
### encode\_utf8\_unblessed($perl\_data)

Downgrade each string fields of the `$perl_data` to utf8 encoded octets.

encode\_utf8\_unblessed will leave blessed references untouched

### decode\_utf8($perl\_data)
### decode\_utf8\_unblessed($perl\_data)

Upgrade each string or numeric fields of the `$perl_data` to multibyte chars.
If there're any malform utf8 octets, transfer them to questionmarks(?).

decode\_utf8\_unblessed will leave blessed references untouched

# CAVEATS

### The input argument of `encode_json` / `encnode_json_unsafe` will be changed

The `encode_json_unsafe` will upgrade all the string or numeric scalar into multibyte char strings
and never back.

Though the `encode_json` will try to convert it back to utf8 encoded octets.
It didn't remember if any of them is originally numeric or multibyte chars already.
They'll all transfer back to utf8 encoded octets.

### The malform octets in the hash key is not handled

The malform octets in the hash key is left as is.
Then the `JSON::XS::encode_json` will complain about that.

# SEE ALSO

[JSON::XS](https://metacpan.org/pod/JSON::XS)

This mod's github repository [https://github.com/CindyLinz/Perl-JSON-XS-ByteString](https://github.com/CindyLinz/Perl-JSON-XS-ByteString)

# AUTHOR

Cindy Wang (CindyLinz)

# COPYRIGHT AND LICENSE

Copyright (C) 2014-2016 by Cindy Wang (CindyLinz)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.
