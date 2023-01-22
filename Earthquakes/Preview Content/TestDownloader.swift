//
//  TestDownloader.swift
//  EarthquakesTests
//
//  Created by Roman Korobskoy on 23.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

final class TestDownloader: HTTPDataDownloader {
    func httpData(from url: URL) async throws -> Data {
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...500_000_000))
        return testQuakesData
    }
}
