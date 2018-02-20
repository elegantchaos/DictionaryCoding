import XCTest
@testable import DictionaryCoding

struct Test : Codable {
  let name : String
}

class DictionaryCodingTests: XCTestCase {
    func testExample() throws {
      let test = Test(name: "Brad")
      let encoder = DictionaryEncoder()
      let encoded = try encoder.encode(test)
      print("\(encoded)")

      let decoder = DictionaryDecoder()
      let decoded = try decoder.decode(Test.self, from: encoded)
      print("\(decoded)")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
