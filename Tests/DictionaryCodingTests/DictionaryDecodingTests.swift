import XCTest
@testable import DictionaryCoding

class DictionaryDecodingTests: XCTestCase {
    
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
    
    func testDecodingWithStandardDefaults() throws {
        // the dictionary is missing some keys, but they can be filled in
        // using default values if we set the missingValue strategy to .useDefault
        let dict : [String:Any] = [:]
        
        let decoder = DictionaryDecoder()
        decoder.missingValueDecodingStrategy = .useStandardDefault
        
        let decoded = try decoder.decode(AllTheTypes.self, from: dict)
        
        XCTAssertEqual(decoded.string, "")
        XCTAssertEqual(decoded.int, 0)
        XCTAssertEqual(decoded.int8, 0)
        XCTAssertEqual(decoded.int16, 0)
        XCTAssertEqual(decoded.int32, 0)
        XCTAssertEqual(decoded.int64, 0)
        XCTAssertEqual(decoded.uint, 0)
        XCTAssertEqual(decoded.uint8, 0)
        XCTAssertEqual(decoded.uint16, 0)
        XCTAssertEqual(decoded.uint32, 0)
        XCTAssertEqual(decoded.uint64, 0)
        XCTAssertEqual(decoded.bool, false)
        XCTAssertEqual(decoded.float, 0)
        XCTAssertEqual(decoded.double, 0)
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
        
        let defaults : [String:Any] = [ "String" : "default", "Int" : 123, "Bool" : true, "Double" : 123.456 ]
        decoder.missingValueDecodingStrategy = .useDefault(defaults: defaults)
        
        let decoded = try decoder.decode(Test.self, from: dict)
        
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertEqual(decoded.label, "default")
        XCTAssertEqual(decoded.age, 123)
        XCTAssertEqual(decoded.flag, true)
        XCTAssertEqual(decoded.value, 123.456)
    }
    
    func testDecodingStringFromURL() throws {
        // if we're expecting a string, but are given a URL, we should be able to cope
        struct Test : Decodable {
            let value : String
        }
        
        let decoder = DictionaryDecoder()

        let encoded1 : [String:Any] = ["value" : URL(fileURLWithPath: "/path")]
        let decoded1 = try decoder.decode(Test.self, from: encoded1)
        XCTAssertEqual(decoded1.value, "file:///path")

        let encoded2 : [String:Any] = ["value" : NSURL(fileURLWithPath: "/path")]
        let decoded2 = try decoder.decode(Test.self, from: encoded2)
        XCTAssertEqual(decoded2.value, "file:///path")
    }

    func testDecodingStringFromUUID() throws {
        // if we're expecting a string, but are given a UUID, we should be able to cope
        struct Test : Decodable {
            let value : String
        }

        let decoder = DictionaryDecoder()

        let uuid = UUID()
        let encoded : [String:Any] = ["value" : uuid]
        let decoded = try decoder.decode(Test.self, from: encoded)
        XCTAssertEqual(decoded.value, uuid.uuidString)
    }

    func testDecodingUUID() throws {
        // if we're expecting a UUID, but are given a String or a CFUUID, we should be able to cope
        struct Test : Decodable {
            let value : UUID
        }
        
        let decoder = DictionaryDecoder()
        
        let uuid = UUID()
        let encoded1 : [String:Any] = ["value" : uuid]
        let decoded1 = try decoder.decode(Test.self, from: encoded1)
        XCTAssertEqual(decoded1.value, uuid)

        let encoded2 : [String:Any] = ["value" : uuid.uuidString]
        let decoded2 = try decoder.decode(Test.self, from: encoded2)
        XCTAssertEqual(decoded2.value, uuid)

        let encoded3 : [String:Any] = ["value" : CFUUIDCreateFromString(nil, uuid.uuidString as CFString)!]
        let decoded3 = try decoder.decode(Test.self, from: encoded3)
        XCTAssertEqual(decoded3.value, uuid)

        // test for crashes when given other slightly random types...
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : 123]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : 123.456]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : true]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : URL(fileURLWithPath: "/test")]))
    }

    func testDecodingURL() throws {
        // if we're expecting a URL, we should be able to cope with getting a string, URL or NSURL
        // if we're expecting a UUID, but are given a String or a CFUUID, we should be able to cope
        struct Test : Decodable {
            let value : URL
        }
        
        let decoder = DictionaryDecoder()
        
        let url = URL(string: "http://elegantchaos.com")!
        let decoded1 = try decoder.decode(Test.self, from: ["value" : url])
        XCTAssertEqual(decoded1.value, url)

        let decoded2 = try decoder.decode(Test.self, from: ["value" : url.absoluteString])
        XCTAssertEqual(decoded2.value, url)

        let decoded3 = try decoder.decode(Test.self, from: ["value" : NSURL(string: url.absoluteString)!])
        XCTAssertEqual(decoded3.value, url)
    }

    
    static var allTests = [
        ("testDecodingAllTheTypes", testDecodingAllTheTypes),
        ("testDecodingNSDictionary", testDecodingNSDictionary),
        ("testDecodingCFDictionary", testDecodingCFDictionary),
        ("testFailureWithMissingKeys", testFailureWithMissingKeys),
        ("testDecodingOptionalValues", testDecodingOptionalValues),
        ("testDecodingWithDefaults", testDecodingWithDefaults),
        ("testDecodingStringFromURL", testDecodingStringFromURL),
        ("testDecodingStringFromUUID", testDecodingStringFromUUID),
        ("testDecodingUUID", testDecodingUUID),
        ("testDecodingURL", testDecodingURL),
        ]
}
