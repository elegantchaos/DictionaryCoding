import XCTest
@testable import DictionaryCoding

class DictionaryDecodingTests: XCTestCase {
    var sut: DictionaryDecoder!

    override func setUp() {
        sut = DictionaryDecoder()
    }

    override func tearDown() {
        sut = nil
    }

    func testDecoding_allTheTypes_shouldSucceed() throws {
        // given
        let encoded: [String: Any] = ["uint32": 123456, "data": "dGVzdA==", "int16": -12345, "int64": -123456789, "uint8": 123, "date": 123456.789, "uint": 123456, "int": -123456, "int8": -123, "bool": 1, "int32": -123456, "double": 12345.6789, "uint64": 123456789, "float": 123.456, "uint16": 12345, "string": "blah"]
        
        // when
        let decoded = try sut.decode(AllTheTypes.self, from: encoded)

        // then
        XCTAssertEqual(decoded.string, "blah")
        XCTAssertEqual(decoded.int, -123456)
        XCTAssertEqual(decoded.int8, -123)
        XCTAssertEqual(decoded.int16, -12345)
        XCTAssertEqual(decoded.int32, -123456)
        XCTAssertEqual(decoded.int64, -123456789)
        XCTAssertEqual(decoded.data, "test".data(using: .utf8))
    }
    
    func testDecoding_NSDictionary_shouldSucceed() throws {
        // given
        let pet1 = NSMutableDictionary()
        pet1["name"] = "Morven"

        let pet2 = NSMutableDictionary()
        pet2["name"] = "Rebus"

        let pets = NSMutableArray()
        pets.add(pet1)
        pets.add(pet2)

        let dict = NSMutableDictionary()
        dict["name"] = "Sam"
        dict["age"] = 48
        dict["pets"] = pets

        // when
        let decoded = try sut.decode(Person.self, from: dict)

        // then
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertEqual(decoded.age, 48)
        XCTAssertEqual(decoded.pets.count, 2)
        XCTAssertEqual(decoded.pets[0].name, "Morven")
        XCTAssertEqual(decoded.pets[1].name, "Rebus")
    }
    
    func testDecoding_CFDictionary_shouldSucceed() throws {
        // given
        let dict = ["name": "Sam", "age": 48, "pets": [["name": "Morven"], ["name": "Rebus"]]] as CFDictionary

        // when
        let decoded = try sut.decode(Person.self, from: dict)

        // then
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertEqual(decoded.age, 48)
        XCTAssertEqual(decoded.pets.count, 2)
        XCTAssertEqual(decoded.pets[0].name, "Morven")
        XCTAssertEqual(decoded.pets[1].name, "Rebus")
    }
    
    func testDecoding_swiftDictionary_shouldSucceed() throws {
        // given
        let dict: [String: Any] = ["name": "Sam", "age": 48, "pets": [["name": "Morven"], ["name": "Rebus"]]]

        // when
        let decoded = try sut.decode(Person.self, from: dict)

        // then
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertEqual(decoded.age, 48)
        XCTAssertEqual(decoded.pets.count, 2)
        XCTAssertEqual(decoded.pets[0].name, "Morven")
        XCTAssertEqual(decoded.pets[1].name, "Rebus")
    }
    
    func testDecoding_withMissingKeys_shouldFail() {
        // given
        let dict = ["name": "Sam", "age": 48] as NSDictionary

        // when/then
        XCTAssertThrowsError(try sut.decode(Person.self, from: dict))
    }
    
    // the dictionary is missing some keys, but decoding shouldn't fail
    // as they correspond to properties that are optional in the struct
    func testDecoding_missingKeysOfOptionalValues_shouldSucceed() throws {
        // given
        struct Test: Codable {
            let name: String
            let label: String?
        }

        let dict: [String: Any] = ["name": "Sam"]

        // when
        let decoded = try sut.decode(Test.self, from: dict)

        // then
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertNil(decoded.label)
    }
    
    // the dictionary is missing some keys, but they can be filled in
    // using default values if we set the missingValue strategy to .useDefault
    func testDecoding_withStandardDefaults_shouldSucceed() throws {
        // given
        let dict: [String: Any] = [:]

        // when
        sut.missingValueDecodingStrategy = .useStandardDefault
        let decoded = try sut.decode(AllTheTypes.self, from: dict)

        // then
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
        XCTAssertEqual(decoded.data, Data())
    }

    // the dictionary is missing some keys, but they can be filled in
    // using default values if we set the missingValue strategy to .useDefault
    func testDecoding_withDefaults_shouldSucceed() throws {
        // given
        struct Test: Codable {
            let name: String
            let label: String
            let age: Int
            let flag: Bool
            let value: Double
        }

        let dict: [String: Any] = ["name": "Sam"]
        let defaults: [String: Any] = ["String": "default", "Int": 123, "Bool": true, "Double": 123.456]

        // when
        sut.missingValueDecodingStrategy = .useDefault(defaults: defaults)
        let decoded = try sut.decode(Test.self, from: dict)

        // then
        XCTAssertEqual(decoded.name, "Sam")
        XCTAssertEqual(decoded.label, "default")
        XCTAssertEqual(decoded.age, 123)
        XCTAssertEqual(decoded.flag, true)
        XCTAssertEqual(decoded.value, 123.456)
    }
    
    // if we're expecting a string, but are given a URL, we should be able to cope
    func testDecoding_stringFromURL_shouldSucceed() throws {
        // given
        struct JustString: Decodable {
            let value: String
        }

        let encoded1: [String: Any] = ["value": URL(fileURLWithPath: "/path")]
        let encoded2: [String: Any] = ["value": NSURL(fileURLWithPath: "/path")]

        // when
        let decoded1 = try sut.decode(JustString.self, from: encoded1)
        let decoded2 = try sut.decode(JustString.self, from: encoded2)

        // then
        XCTAssertEqual(decoded1.value, "file:///path")
        XCTAssertEqual(decoded2.value, "file:///path")
    }

    func testDecoding_urlFromString_shouldSucceed() throws {
        // given
        struct JustURL: Decodable {
            let value: URL
        }

        let encoded: [String: Any] = ["value": URL(fileURLWithPath: "/path").absoluteURL]

        // when
        let decoded = try sut.decode(JustURL.self, from: encoded)

        // then
        XCTAssertEqual(decoded.value, URL(string: "file:///path"))
    }

    // if we're expecting a string, but are given a UUID, we should be able to cope
    func testDecoding_stringFromUUID_shouldSucceed() throws {
        // given
        struct JustString: Decodable {
            let value: String
        }

        let uuid = UUID()
        let encoded: [String: Any] = ["value": uuid]

        // when
        let decoded = try sut.decode(JustString.self, from: encoded)

        // then
        XCTAssertEqual(decoded.value, uuid.uuidString)
    }

    // if we're expecting a UUID, but are given a String or a CFUUID, we should be able to cope
    func testDecoding_uuidFromVariousUUIDTypes_shouldSucceed() throws {
        // given
        struct JustUUID: Decodable {
            let value: UUID
        }
        
        let uuid = UUID()
        let encoded1: [String: Any] = ["value": uuid]
        let encoded2: [String: Any] = ["value": uuid.uuidString]
        let encoded3: [String: Any] = ["value": CFUUIDCreateFromString(nil, uuid.uuidString as CFString)!]

        // when
        let decoded1 = try sut.decode(JustUUID.self, from: encoded1)
        let decoded2 = try sut.decode(JustUUID.self, from: encoded2)
        let decoded3 = try sut.decode(JustUUID.self, from: encoded3)

        // then
        XCTAssertEqual(decoded1.value, uuid)
        XCTAssertEqual(decoded2.value, uuid)
        XCTAssertEqual(decoded3.value, uuid)
    }

    // test for crashes when given other slightly random types...
    func testDecoding_uuidFromUnsupportedTypes_shouldFail() throws {
        // given
        struct JustUUID: Decodable {
            let value: UUID
        }

        // when/then
        XCTAssertThrowsError(try sut.decode(JustUUID.self, from: ["value": 123]))
        XCTAssertThrowsError(try sut.decode(JustUUID.self, from: ["value": 123.456]))
        XCTAssertThrowsError(try sut.decode(JustUUID.self, from: ["value": true]))
        XCTAssertThrowsError(try sut.decode(JustUUID.self, from: ["value": URL(fileURLWithPath: "/test")]))
    }

    // if we're expecting a URL, we should be able to cope with getting a string, URL or NSURL
    // if we're expecting a UUID, but are given a String or a CFUUID, we should be able to cope
    func testDecoding_urlFromVariousTypes_shouldSucceed() throws {
        // given
        struct JustURL: Decodable {
            let value: URL
        }
        
        let url = URL(fileURLWithPath: "/test")

        // when
        let decoded1 = try sut.decode(JustURL.self, from: ["value": url])
        let decoded2 = try sut.decode(JustURL.self, from: ["value": url.absoluteString])
        let decoded3 = try sut.decode(JustURL.self, from: ["value": NSURL(string: url.absoluteString)!])

        // then
        XCTAssertEqual(decoded1.value, url)
        XCTAssertEqual(decoded2.value, url)
        XCTAssertEqual(decoded3.value, url)
    }

    func testDecoding_dataFromVariousTypes_shouldSucceed() throws {
        // given
        struct JustData: Codable {
            let data: Data
        }

        let encoded1: [String: Any] = ["data": "dGVzdA=="]
        let encoded2: [String: Any] = ["data": "test2".data(using: .utf8)!]

        // when
        let decoded1 = try sut.decode(JustData.self, from: encoded1)
        let decoded2 = try sut.decode(JustData.self, from: encoded2)

        // then
        XCTAssertEqual(decoded1.data, "test".data(using: .utf8))
        XCTAssertEqual(decoded2.data, "test2".data(using: .utf8))
    }
}
