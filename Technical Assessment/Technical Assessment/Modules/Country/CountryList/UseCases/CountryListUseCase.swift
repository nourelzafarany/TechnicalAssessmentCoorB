//
//  CountryListUseCase.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation

protocol GetCountryListUseCaseProtocol {
    func execute(forceRefresh: Bool) async throws -> [CountryEntity]
}

struct GetCountryListUseCase: GetCountryListUseCaseProtocol {
    private let repo: CountryListRepositoryProtocol
    init(repo: CountryListRepositoryProtocol) {
        self.repo = repo
    }

    func execute(forceRefresh: Bool = false) async throws -> [CountryEntity] {
        let list = try await repo.getCountries(forceRefresh: forceRefresh)
        return list.sorted{$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending}
    }
}
