//
//  CountryListRepo.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation

protocol CountryListRepositoryProtocol {
    func getCountries(forceRefresh: Bool) async throws -> [CountryEntity]
}

struct CountryListRepository: CountryListRepositoryProtocol {
    private let remote: CountryListRemoteDataSourceProtocol
    private let local: CountryListLocalDataSource?
    private let mapper: CountryMapper
    private let freshness: TimeInterval
    private let now: () -> Date

    init(
        remote: CountryListRemoteDataSourceProtocol,
        local: CountryListLocalDataSource? = nil,
        mapper: CountryMapper = .init(),
        freshness: TimeInterval = 10 * 60,
        now: @escaping () -> Date = Date.init
    ) {
        self.remote = remote
        self.local = local
        self.mapper = mapper
        self.freshness = freshness
        self.now = now
    }

    func getCountries(forceRefresh: Bool = false) async throws -> [CountryEntity] {
        let responses = try await remote.fetchCountries()
        let countries = responses.map {
            mapper.fromRespToEntity($0)
        }
        if let local = local {
            let localCountries = countries.map {
                mapper.fromDtoToLocal($0)
            }
            try? local.saveCountries(localCountries)
        }
        return countries
    }
}
