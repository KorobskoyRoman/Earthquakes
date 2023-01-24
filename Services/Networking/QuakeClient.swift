//
//  QuakeClient.swift
//  EarthquakesTests
//
//  Created by Roman Korobskoy on 23.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

final actor QuakeClient {
    var quakes: [Quake] {
        get async throws {
            let data = try await downloader.httpData(from: feedURL)
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)
            var updatedQuakes = allQuakes.quakes
            if let olderThanOneHour = updatedQuakes.firstIndex(where: {
                $0.time.timeIntervalSinceNow > 3600
            }) {
                let indexRange = updatedQuakes.startIndex..<olderThanOneHour
                try await withThrowingTaskGroup(of: (Int, QuakeLocation).self, body: { group in
                    for index in indexRange {
                        group.addTask {
                            let location = try await self.quakeLocation(from: allQuakes.quakes[index].detail)
                            return (index, location)
                        }
                    }
                    while let result = await group.nextResult() {
                        switch result {
                        case .failure(let error):
                            throw error
                        case .success(let (index, location)):
                            updatedQuakes[index].location = location
                        }
                    }
                })
            }
            return updatedQuakes
        }
    }

    private let quakeCache: NSCache<NSString, CacheEntryObject> = NSCache()

    private lazy var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    private let feedURL = URL(
        string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    )!

    private let downloader: any HTTPDataDownloader

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    func quakeLocation(from url: URL) async throws -> QuakeLocation {
        if let cached = quakeCache[url] {
            switch cached {
            case .inProgress(let task):
                return try await task.value
            case .ready(let location):
                return location
            }
        }

        let task = Task<QuakeLocation, Error> {
            let data = try await downloader.httpData(from: url)
            let location = try decoder.decode(QuakeLocation.self, from: data)
            return location
        }
        quakeCache[url] = .inProgress(task)
        do {
            let location = try await task.value
            return location
        } catch {
            quakeCache[url] = nil
            throw error
        }
    }
}
