//
//  EarthquakesTests.swift
//  EarthquakesTests
//
//  Created by Roman Korobskoy on 19.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest
@testable import Earthquakes

final class EarthquakesTests: XCTestCase {
    func testGeoJSONDecoderDecodesQuake() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        let quake = try decoder.decode(Quake.self, from: testFeature_nc73649170)

        XCTAssertEqual(quake.code, "73649170")

        let expectedSeconds = TimeInterval(1636129710550) / 1000
        let decodedSeconds = quake.time.timeIntervalSince1970

        XCTAssertEqual(expectedSeconds, decodedSeconds, accuracy: 0.00001)
    }

    func testGeoJSONDecodesTsunami() throws {
        let decoded = try JSONDecoder().decode(Quake.self, from: testFeature_nc73649170)

        XCTAssertEqual(decoded.tsunami, 0)
    }
}
