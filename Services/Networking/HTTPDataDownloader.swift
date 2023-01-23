//
//  HTTPDataDownloader.swift
//  EarthquakesTests
//
//  Created by Roman Korobskoy on 23.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

fileprivate let validStatus = 200...299

protocol HTTPDataDownloader {
    func httpData(from: URL) async throws -> Data
}

extension URLSession: HTTPDataDownloader {
    func httpData(from url: URL) async throws -> Data {
        guard let (data, response) = try await self.data(
            from: url, delegate: nil
        ) as? (Data, HTTPURLResponse),
              validStatus.contains(response.statusCode) else {
            throw QuakeError.networkError
        }
        return data
    }
}
