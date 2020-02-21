[![Test results][tests shield]][actions] [![Latest release][release shield]][releases] [![Swift 5.0][swift shield]][swift] ![Platforms: iOS, macOS, tvOS, watchOS, Linux][platforms shield]

[swift]: https://swift.org

[releases]: https://github.com/elegantchaos/DictionaryCoding/releases
[actions]: https://github.com/elegantchaos/DictionaryCoding/actions

[release shield]: https://img.shields.io/github/v/release/elegantchaos/DictionaryCoding
[swift shield]: https://img.shields.io/badge/swift-5.0-F05138.svg "Swift 5.0"
[platforms shield]: https://img.shields.io/badge/platforms-iOS_macOS_tvOS_watchOS_Linux-lightgrey.svg?style=flat "iOS, macOS, tvOS, watchOS, Linux"
[tests shield]: https://github.com/elegantchaos/DictionaryCoding/workflows/Tests/badge.svg

# DictionaryCoding

This is an implementation of Swift's Encoder/Decoder protocols which uses `NSDictionary` as its underlying container mechanism.

It allows you to take a native swift class or struct that confirms to the Codable protocol and convert it to, or initialise it from, a dictionary.

A lot of the code is actually taken from the Swift Foundation library's own `JSONEncoder` and `JSONDecoder` classes.

It turns out that those class actually work by using `NSDictionary` as an intermediate step between JSON and the native type to be encoded/decoded. Unfortunately the underlying `NSDictionary` support isn't exposed by Foundation, which is why I've done so here.

See [this blog post](http://elegantchaos.com/2018/02/21/decoding-dictionaries-in-swift.html) for a bit more detail!

### Build Instructions

At the moment this module is best built using the Swift Package Manager with `swift build`.

The unit tests can be run with `swift test`.

An Xcode project can be generated with `swift package generate-xcodeproj  --xcconfig-overrides DictionaryCoding.xcconfig`.

A CocoaPods `.podspec` file is included. I don't use CocoaPods myself though, so I can't be entirely sure that I haven't broken something (or forgotten to update something).

Please file issues (or even better, pull requests) for support for other build systems.
