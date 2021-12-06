import XCTest
@testable import DictionaryCoding

struct Pet: Codable, Equatable {
    let name: String
}

struct Person: Codable, Equatable {
    let name: String
    let age: Int
    let pets: [Pet]
}

struct AllTheTypes: Codable {
    let string: String
    let int: Int
    let int8: Int8
    let int16: Int16
    let int32: Int32
    let int64: Int64
    let uint: UInt
    let uint8: UInt8
    let uint16: UInt16
    let uint32: UInt32
    let uint64: UInt64
    let float: Float
    let double: Double
    let bool: Bool
    let date: Date
    let data: Data
}

class DictionaryEncodingTests: XCTestCase {
    var sut: DictionaryEncoder!

    override func setUp() {
        sut = DictionaryEncoder()
    }

    override func tearDown() {
        sut = nil
    }

    func testEncoding_allTheTypes_shouldSucceed() throws {
        // given
        let test = AllTheTypes(string: "Hello World", int: -123456, int8: -123, int16: -12345, int32: -123456, int64: -123456789, uint: 123456, uint8: 123, uint16: 12345, uint32: 123456, uint64: 123456789, float: 123.456, double: 12345.6789, bool: true, date: Date(timeIntervalSinceReferenceDate: 123456.789), data: "test".data(using: String.Encoding.utf8)!)

        // when
        let encoded = try sut.encode(test) as [String:Any]

        // then
        XCTAssertEqual(encoded["string"] as? String, "Hello World")
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
        XCTAssertEqual(encoded["date"] as? Date, Date(timeIntervalSinceReferenceDate: 123456.789))
        XCTAssertEqual(encoded["data"] as? Data, "test".data(using: String.Encoding.utf8)!)
    }

    func testEncoding_variousDateFormats_shouldSucceed() throws {
        // given
        struct JustDate: Codable {
            let date: Date
        }

        let test = JustDate(date: Date(timeIntervalSinceReferenceDate: 123456.789))

        // when
        let encoded1 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .deferredToDate
        let encoded2 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .iso8601
        let encoded3 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .millisecondsSince1970
        let encoded4 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .secondsSince1970
        let encoded5 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .deferredToDate
        let encoded6 = try sut.encode(test) as [String: Any]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        sut.dateEncodingStrategy = .formatted(formatter)
        let encoded7 = try sut.encode(test) as [String: Any]

        sut.dateEncodingStrategy = .custom { _, encoder in
            try "some custom encoding".encode(to: encoder)
        }
        let encoded8 = try sut.encode(test) as [String: Any]

        // then
        XCTAssertEqual(encoded1["date"] as? Date, Date(timeIntervalSinceReferenceDate: 123456.789))
        XCTAssertEqual(encoded2["date"] as? TimeInterval, 123456.789)
        XCTAssertEqual(encoded3["date"] as? String, "2001-01-02T10:17:36Z")
        XCTAssertEqual(encoded4["date"] as? Double, 978430656789.0)
        XCTAssertEqual(encoded5["date"] as? Double, 978430656.78900003)
        XCTAssertEqual(encoded6["date"] as? TimeInterval, 123456.789)
        XCTAssertEqual(encoded7["date"] as? String, "January 2")
        XCTAssertEqual(encoded8["date"] as? String, "some custom encoding")
    }
    
    func testEncoding_variousDataFormats_shouldSucceed() throws {
        // given
        struct JustData: Codable {
            let data: Data
        }

        let test = JustData(data: "Foo".data(using: .utf8)!)

        // when
        let encoded1 = try sut.encode(test) as [String: Any]

        sut.dataEncodingStrategy = .base64
        let encoded2 = try sut.encode(test) as [String: Any]

        sut.dataEncodingStrategy = .deferredToData
        let encoded3 = try sut.encode(test) as [String: Any]

        sut.dataEncodingStrategy = .custom { _, encoder in
            try "some custom encoding".encode(to: encoder)
        }
        let encoded4 = try sut.encode(test) as [String: Any]

        // then
        XCTAssertEqual(encoded1["data"] as? Data, "Foo".data(using: .utf8))
        XCTAssertEqual(encoded2["data"] as? String, "Rm9v")
        XCTAssertEqual(encoded3["data"] as? [UInt8], [70, 111, 111])
        XCTAssertEqual(encoded4["data"] as? String, "some custom encoding")
    }

    func testEncoding_asNSDictionary_shouldSucceed() throws {
        // given
        let test = Person(name: "Sam", age: 48, pets:[Pet(name: "Morven"), Pet(name: "Rebus")])

        // when
        let encoded = try sut.encode(test) as NSDictionary

        // then
        XCTAssertEqual(encoded["name"] as? String, "Sam")
        XCTAssertEqual(encoded["age"] as? Int, 48)
        let pets = try XCTUnwrap(encoded["pets"] as? [NSDictionary])
        XCTAssertEqual(pets[0]["name"] as? String, "Morven")
        XCTAssertEqual(pets[1]["name"] as? String, "Rebus")
    }
    
    func testEncoding_asSwiftDictionary_shouldSucceed() throws {
        // given
        let test = Person(name: "Sam", age: 48, pets: [Pet(name: "Morven"), Pet(name: "Rebus")])

        // when
        let encoded = try sut.encode(test) as [String: Any]

        // then
        XCTAssertEqual(encoded["name"] as? String, "Sam")
        XCTAssertEqual(encoded["age"] as? Int, 48)
        let pets = try XCTUnwrap(encoded["pets"] as? [NSDictionary])
        XCTAssertEqual(pets[0]["name"] as? String, "Morven")
        XCTAssertEqual(pets[1]["name"] as? String, "Rebus")
    }

    // the struct's optional values should not get written into the dictionary
    // if they are nil
    func testEncoding_optionalValues_shouldSucceed() throws {
        // given
        struct Test: Codable {
            let name: String
            let label: String?
        }

        let test = Test(name: "Sam", label: nil)

        // when
        let encoded = try sut.encode(test) as NSDictionary

        // then
        XCTAssertEqual(encoded["name"] as? String, "Sam")
        XCTAssertEqual(encoded["label"] as? String, nil)
    }

    func testEncoding_url_shouldSucceed() throws {
        // given
        struct Test: Encodable {
            let value: URL
        }
        
        let url = URL(string: "http://elegantchaos.com")!
        let test = Test(value: url)

        // when
        let encoded = try sut.encode(test) as [String:Any]

        // then
        XCTAssertEqual(encoded["value"] as? URL, url)
    }
}
