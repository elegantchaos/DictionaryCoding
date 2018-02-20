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

struct Test : Codable {
  let name : String
  let label : String?
}

class DictionaryCodingTests: XCTestCase {
  
    func testEncodingAsNSDictionary() throws {
      let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])
      let encoder = DictionaryEncoder()
      let encoded = try encoder.encode(test) as NSDictionary
      XCTAssertEqual(encoded["name"] as? String, "Sam")
      XCTAssertEqual(encoded["age"] as? Int, 48)
    }

  func testEncodingAsSwiftDictionary() throws {
    let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])
    let encoder = DictionaryEncoder()
    let encoded = try encoder.encode(test) as [String:Any]
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
 
  func testDecodingSwiftDictionary() throws {
    let dict : [String:Any] = [ "name" : "Sam", "age" : 48, "pets" : [ ["name" : "Morven"], ["name" : "Rebus"]]]
    
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
  
  func testDecodingOptionalValues() throws {
    // the dictionary is missing some keys, but decoding shouldn't fail
    // as they correspond to properties that are optional in the struct
    
    let dict : [String:Any] = [ "name" : "Sam" ]
    
    let decoder = DictionaryDecoder()
    let decoded = try decoder.decode(Test.self, from: dict)
    
    XCTAssertEqual(decoded.name, "Sam")
    XCTAssertNil(decoded.label)
  }

  func testEncodingOptionalValues() throws {
    // the struct's optional values should not get written into the dictionary
    // if they are nil
    
    let test = Test(name: "Sam", label: nil)
    let encoder = DictionaryEncoder()
    let encoded = try encoder.encode(test) as NSDictionary
    XCTAssertEqual(encoded["name"] as? String, "Sam")
    XCTAssertEqual(encoded.allKeys.count, 1)
  }

  func testDecodingWithDefaults() throws {
    // the dictionary is missing some keys, but they can be filled in
    // using default values if we set the missingValue strategy to .useDefault
    struct Test : Codable {
      let name : String
      let label : String
      let age : Int
      let flag : Bool
      let value : Double
    }
    
    let dict : [String:Any] = [ "name" : "Sam" ]
    
    let decoder = DictionaryDecoder()
    decoder.missingValueDecodingStrategy = .useDefault
    
    let decoded = try decoder.decode(Test.self, from: dict)
    
    XCTAssertEqual(decoded.name, "Sam")
    XCTAssertEqual(decoded.label, "")
    XCTAssertEqual(decoded.age, 0)
    XCTAssertEqual(decoded.flag, false)
    XCTAssertEqual(decoded.value, 0.0)
  }

  static var allTests = [
        ("testEncodingAsNSDictionary", testEncodingAsNSDictionary),
        ("testEncodingAsSwiftDictionary", testEncodingAsSwiftDictionary),
        ("testDecodingNSDictionary", testDecodingNSDictionary),
        ("testDecodingCFDictionary", testDecodingCFDictionary),
        ("testFailureWithMissingKeys", testFailureWithMissingKeys),
        ("testDecodingOptionalValues", testDecodingOptionalValues),
        ("testEncodingOptionalValues", testEncodingOptionalValues),
        ("testDecodingWithDefaults", testDecodingWithDefaults),
    ]
}
