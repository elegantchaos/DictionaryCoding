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

struct AllTheTypes : Codable {
  let string : String
  let int : Int
  let int8 : Int8
  let int16 : Int16
  let int32 : Int32
  let int64 : Int64
  let uint : UInt
  let uint8 : UInt8
  let uint16 : UInt16
  let uint32 : UInt32
  let uint64 : UInt64
  let float : Float
  let double : Double
  let bool : Bool
  let date : Date
  let data : Data
}

class DictionaryCodingTests: XCTestCase {
  func testEncodingAllTheTypes() throws {
    let date = Date(timeIntervalSinceReferenceDate: 123456.789)
    let test = AllTheTypes(
      string: "blah",
      int: -123456, int8: -123, int16: -12345, int32: -123456, int64: -123456789,
      uint: 123456, uint8: 123, uint16: 12345, uint32: 123456, uint64: 123456789,
      float: 123.456, double: 12345.6789,
      bool: true,
      date: date,
      data: "test".data(using: String.Encoding.utf8)!
    )
    let encoder = DictionaryEncoder()
    let encoded = try encoder.encode(test) as [String:Any]
    XCTAssertEqual(encoded["string"] as? String, "blah")
    XCTAssertEqual(encoded["int"] as? Int, -123456)
    XCTAssertEqual(encoded["int8"] as? Int8, -123)
    XCTAssertEqual(encoded["int16"] as? Int16, -12345)
    XCTAssertEqual(encoded["int32"] as? Int32, -123456)
    XCTAssertEqual(encoded["int64"] as? Int64, -123456789)
    XCTAssertEqual(encoded["uint"] as? UInt, 123456)
    XCTAssertEqual(encoded["uint8"] as? UInt8, 123)
    XCTAssertEqual(encoded["uint16"] as? UInt16, 12345)
    XCTAssertEqual(encoded["uint32"] as? UInt32, 123456)
    XCTAssertEqual(encoded["uint64"] as? UInt64, 123456789)
    XCTAssertEqual(encoded["float"] as? Float, 123.456)
    XCTAssertEqual(encoded["double"] as? Double, 12345.6789)
    XCTAssertEqual(encoded["bool"] as? Bool, true)
    XCTAssertEqual(encoded["date"] as? Double, 123456.789)
    XCTAssertEqual(encoded["data"] as? String, "dGVzdA==")
  }
  
  func testDecodingAllTheTypes() throws {
    let encoded : [String:Any] = ["uint32": 123456, "data": "dGVzdA==", "int16": -12345, "int64": -123456789, "uint8": 123, "date": 123456.789, "uint": 123456, "int": -123456, "int8": -123, "bool": 1, "int32": -123456, "double": 12345.6789, "uint64": 123456789, "float": 123.456, "uint16": 12345, "string": "blah"]
    
    let decoder = DictionaryDecoder()
    let decoded = try decoder.decode(AllTheTypes.self, from: encoded)

    XCTAssertEqual(decoded.string, "blah")
    XCTAssertEqual(decoded.int, -123456)
    XCTAssertEqual(decoded.int8, -123)
    XCTAssertEqual(decoded.int16, -12345)
    XCTAssertEqual(decoded.int32, -123456)
    XCTAssertEqual(decoded.int64, -123456789)
  }
  
  func testEncodingAsNSDictionary() throws {
    let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])
    let encoder = DictionaryEncoder()
    let encoded = try encoder.encode(test) as NSDictionary
    XCTAssertEqual(encoded["name"] as? String, "Sam")
    XCTAssertEqual(encoded["age"] as? Int, 48)
    let pets = encoded["pets"] as! [NSDictionary]
    XCTAssertEqual(pets[0]["name"] as? String, "Morven")
    XCTAssertEqual(pets[1]["name"] as? String, "Rebus")
  }
  
  func testEncodingAsSwiftDictionary() throws {
    let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])
    let encoder = DictionaryEncoder()
    let encoded = try encoder.encode(test) as [String:Any]
    XCTAssertEqual(encoded["name"] as? String, "Sam")
    XCTAssertEqual(encoded["age"] as? Int, 48)
    let pets = encoded["pets"] as! [NSDictionary]
    XCTAssertEqual(pets[0]["name"] as? String, "Morven")
    XCTAssertEqual(pets[1]["name"] as? String, "Rebus")
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
