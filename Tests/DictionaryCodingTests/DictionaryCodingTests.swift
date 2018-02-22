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

struct JustDate : Codable {
    let date : Date
}

struct JustData : Codable {
    let data : Data
}

class DictionaryCodingTests: XCTestCase {
    func testEncodingDateFormats() throws {
        let date = JustDate(date: Date(timeIntervalSinceReferenceDate: 123456.789))
        let encoder = DictionaryEncoder()
        let encoded1 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded1["date"] as? TimeInterval, 123456.789)
        
        encoder.dateEncodingStrategy = .iso8601
        let encoded2 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded2["date"] as? String, "2001-01-02T10:17:36Z")
        
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encoded3 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded3["date"] as? Double, 978430656789.0)
        
        encoder.dateEncodingStrategy = .secondsSince1970
        let encoded4 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded4["date"] as? Double, 978430656.78900003)
        
        encoder.dateEncodingStrategy = .deferredToDate
        let encoded5 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded5["date"] as? TimeInterval, 123456.789)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        encoder.dateEncodingStrategy = .formatted(formatter)
        let encoded6 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded6["date"] as? String, "January 2")
        
        var customEncoderCalled = false
        encoder.dateEncodingStrategy = .custom({ (date, encoder) in
            customEncoderCalled = true
            try "some custom encoding".encode(to: encoder)
        })
        let encoded7 = try encoder.encode(date) as [String:Any]
        XCTAssertEqual(encoded7["date"] as? String, "some custom encoding")
        XCTAssertEqual(customEncoderCalled, true)
    }
    
    func testEncodingDataFormats() throws {
        let data = JustData(data: "blah".data(using: String.Encoding.utf8)!)
        let encoder = DictionaryEncoder()
        encoder.dataEncodingStrategy = .base64
        let encoded1 = try encoder.encode(data) as [String:Any]
        XCTAssertEqual(encoded1["data"] as? String, "YmxhaA==")
        
        encoder.dataEncodingStrategy = .deferredToData
        let encoded2 = try encoder.encode(data) as [String:Any]
        XCTAssertEqual(encoded2["data"] as! [Int8], [98, 108, 97, 104])
        
        var customEncoderCalled = false
        encoder.dataEncodingStrategy = .custom({ (date, encoder) in
            customEncoderCalled = true
            try "some custom encoding".encode(to: encoder)
        })
        let encoded3 = try encoder.encode(data) as [String:Any]
        XCTAssertEqual(encoded3["data"] as? String, "some custom encoding")
        XCTAssertEqual(customEncoderCalled, true)
    }
    
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

        let encoded3 : [String:Any] = ["value" : CFUUIDCreateFromString(nil, uuid.uuidString as CFString)]
        let decoded3 = try decoder.decode(Test.self, from: encoded3)
        XCTAssertEqual(decoded3.value, uuid)

        // test for crashes when given other slightly random types...
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : 123]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : 123.456]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : true]))
        XCTAssertThrowsError(try decoder.decode(Test.self, from: ["value" : URL(fileURLWithPath: "/test")]))
    }

    static var allTests = [
        ("testEncodingDataFormats", testEncodingDataFormats),
        ("testEncodingDateFormats", testEncodingDateFormats),
        ("testEncodingAllTheTypes", testEncodingAllTheTypes),
        ("testDecodingAllTheTypes", testDecodingAllTheTypes),
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
