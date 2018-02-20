# DictionaryCoding

This is an implementation of Swift's Encoder/Decoder protocols which uses `NSDictionary` as its underlying container mechanism.

It allows you to take a native swift class or struct that confirms to the Codable protocol and convert it to, or initialise it from, a dictionary.

The code is actually largely taken from the Swift Foundation library's own `JSONEncoder` and `JSONDecoder` classes. 

Those class actually works by using `NSDictionary` as an intermediate step between JSON and the native type to be encoded/decoded.  

Unfortunately the underlying `NSDictionary` support isn't exposed by Foundation, which is why I've done so here. 


