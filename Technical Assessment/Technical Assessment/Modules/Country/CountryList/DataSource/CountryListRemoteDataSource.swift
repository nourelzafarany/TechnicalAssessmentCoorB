//
//  CountryListRemoteDataSource.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation

protocol CountryListRemoteDataSourceProtocol {
    func fetchCountries() async throws -> [CountryListResponse]
}

struct CountryListRemoteDataSource: CountryListRemoteDataSourceProtocol {
    func fetchCountries() async throws -> [CountryListResponse] {
        let url = URL(string: "https://restcountries.com/v2/all?fields=name,alpha2Code,capital,currencies")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([CountryListResponse].self, from: data)
    }
}
