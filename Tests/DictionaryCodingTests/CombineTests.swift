#if canImport(Combine)
import Combine
import XCTest
@testable import DictionaryCoding


@available(iOS 13.0, *)
class CombineTests: XCTestCase {
    let people = [
        Person(name: "Sam", age: 48, pets: [Pet(name: "Morven"), Pet(name: "Rebus")]),
        Person(name: "Jon", age: 30, pets: [Pet(name: "Cougar")])
    ]

    let dicts : [[String: Any]] = [
        ["name": "Sam", "age": 48, "pets": [["name": "Morven"], ["name": "Rebus"]]],
        ["name": "Jon", "age": 30, "pets": [["name": "Cougar"]]]
    ]

    let encoder = DictionaryEncoder()
    let decoder = DictionaryDecoder()

    func testTopLevelDecoder() throws {
        var decoded = [Person]()

        _ = dicts.publisher
            .decode(type: Person.self, decoder: decoder)
            .assertNoFailure()
            .sink { decoded.append($0) }

        XCTAssertEqual(decoded, people)
    }

    func testTopLevelEncoder() throws {
        var encoded = [[String: Any]]()

        _ = people.publisher
            .encode(encoder: encoder)
            .assertNoFailure()
            .sink { encoded.append($0) }

        XCTAssertEqual(encoded.count, 2)
        let sam = encoded[0]
        XCTAssertEqual(sam["name"] as? String, "Sam")
        XCTAssertEqual(sam["age"] as? Int, 48)
        let samPets = sam["pets"] as? [[String: String]]
        XCTAssertEqual(samPets, dicts[0]["pets"] as? [[String: String]])
        let jon = encoded[1]
        XCTAssertEqual(jon["name"] as? String, "Jon")
        XCTAssertEqual(jon["age"] as? Int, 30)
        let jonPets = jon["pets"] as? [[String: String]]
        XCTAssertEqual(jonPets, dicts[1]["pets"] as? [[String: String]])
    }

    static var allTests = [
        ("testTopLevelDecoder", testTopLevelDecoder),
        ("testTopLevelEncoder", testTopLevelEncoder)
    ]
}

#endif
