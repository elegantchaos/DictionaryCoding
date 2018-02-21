# DictionaryCoding

This is an implementation of Swift's Encoder/Decoder protocols which uses `NSDictionary` as its underlying container mechanism.

It allows you to take a native swift class or struct that confirms to the Codable protocol and convert it to, or initialise it from, a dictionary.

A lot of the code is actually taken from the Swift Foundation library's own `JSONEncoder` and `JSONDecoder` classes.

It turns out that those class actually work by using `NSDictionary` as an intermediate step between JSON and the native type to be encoded/decoded. Unfortunately the underlying `NSDictionary` support isn't exposed by Foundation, which is why I've done so here.

See [this blog post](http://elegantchaos.com/2018/02/21/decoding-dictionaries-in-swift.html) for a bit more detail!
