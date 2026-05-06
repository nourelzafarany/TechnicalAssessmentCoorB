//
//  CountryListLocalDataSource.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation
protocol CountryListLocalDataSourceProtocol {
    func loadCountries() throws -> [CountryListResponse]
    func saveCountries(_ countries: [CountryEntity]) throws
    func lastUpdatedAt() -> Date?
}


// MARK: - File-based implementation
struct CountryListLocalDataSource: CountryListLocalDataSourceProtocol {
    private let itemsURL: URL
    private let metaURL: URL

    init() {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.itemsURL = dir.appendingPathComponent("countries.json")
        self.metaURL  = dir.appendingPathComponent("countries_meta.json")
    }

    func loadCountries() throws -> [CountryListResponse] {
        guard FileManager.default.fileExists(atPath: itemsURL.path) else { return [] }
        let data = try Data(contentsOf: itemsURL)
        return try JSONDecoder().decode([CountryListResponse].self, from: data)
    }

    func saveCountries(_ countries: [CountryEntity]) throws {
//        let data = try JSONEncoder().encode(countries)
//        try data.write(to: itemsURL, options: .atomic)
//
//        // store a simple updatedAt timestamp for freshness checks
//        let meta = try JSONEncoder().encode(["updatedAt": Date()])
//        try meta.write(to: metaURL, options: .atomic)
    }

    func lastUpdatedAt() -> Date? {
        guard
            let data = try? Data(contentsOf: metaURL),
            let dict = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return nil }
        return dict["updatedAt"]
    }
}

