import XCTest
@testable import DictionaryCoding

struct Pet : Codable {
  let name : String
}

struct Person : Codable {
  let name : String
  let age : Int
  let pets : [Pet]
}

class DictionaryCodingTests: XCTestCase {
  
    func testEncoding() throws {
      let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])
      let encoder = DictionaryEncoder()
      let encoded = try encoder.encode(test)
      XCTAssertEqual(encoded["name"] as? String, "Sam")
      XCTAssertEqual(encoded["age"] as? Int, 48)
    }

  func testDecodingNSDictionary() throws {
    let pet1 : NSMutableDictionary = NSMutableDictionary()
    pet1["name"] = "Morven"
    let pet2 : NSMutableDictionary = NSMutableDictionary()
    pet2["name"] = "Rebus"
    let pets : NSMutableArray = NSMutableArray()
    pets.add(pet1)
    pets.add(pet2)
    let dict : NSMutableDictionary = NSMutableDictionary()
    dict["name"] = "Sam"
    dict["age"] = 48
    dict["pets"] = pets
    
    let decoder = DictionaryDecoder()
    let decoded = try decoder.decode(Person.self, from: dict)
    
    XCTAssertEqual(decoded.name, "Sam")
    XCTAssertEqual(decoded.age, 48)
    XCTAssertEqual(decoded.pets.count, 2)
    XCTAssertEqual(decoded.pets[0].name, "Morven")
    XCTAssertEqual(decoded.pets[1].name, "Rebus")
  }

  func testDecodingCFDictionary() throws {
    let dict = [ "name" : "Sam", "age" : 48, "pets" : [ ["name" : "Morven"], ["name" : "Rebus"]]] as CFDictionary
    
    let decoder = DictionaryDecoder()
    let decoded = try decoder.decode(Person.self, from: dict)
    
    XCTAssertEqual(decoded.name, "Sam")
    XCTAssertEqual(decoded.age, 48)
    XCTAssertEqual(decoded.pets.count, 2)
    XCTAssertEqual(decoded.pets[0].name, "Morven")
    XCTAssertEqual(decoded.pets[1].name, "Rebus")
  }
  
  func testFailureWithMissingKeys() {
    let dict = [ "name" : "Sam", "age" : 48 ] as NSDictionary
    let decoder = DictionaryDecoder()
    XCTAssertThrowsError(try decoder.decode(Person.self, from: dict))
  }
  
  static var allTests = [
        ("testEncoding", testEncoding),
        ("testDecodingNSDictionary", testDecodingNSDictionary),
        ("testDecodingCFDictionary", testDecodingCFDictionary),
    ]
}
