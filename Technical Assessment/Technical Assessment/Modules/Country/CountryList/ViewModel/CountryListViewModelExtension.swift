//
//  CountryListViewModelExtension.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation

extension CountryListViewModel {    
    private func key(for c: CountryEntity) -> String {
        let code = c.alpha2Code.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty { return code.uppercased() }
        return c.id
    }

    var displayedCountries: [CountryEntity] {
        let userKeys = Set(userAddedCountries.map { key(for: $0) })
        let remainingAPI = countries.filter { !userKeys.contains(key(for: $0)) }
        return userAddedCountries + remainingAPI
    }

    var filteredCountries: [CountryEntity] {
        let base = displayedCountries
        let q = searchWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    func delete(country: CountryEntity) {
        let targetKey = key(for: country)
        if userAddedCountries.contains(where: { key(for: $0) == targetKey }) {
            userAddedCountries.removeAll { key(for: $0) == targetKey }
        } else {
            countries.removeAll { key(for: $0) == targetKey }
        }
    }

    func addCustomCountry(_ draft: CountryDraft) {
        let d = draft.trimmed()

        guard !d.name.isEmpty, !d.alpha2Code.isEmpty, !d.flagPNG.isEmpty else {
            errorMessage = "Please fill all fields: name, code, and flag URL."
            return
        }

        guard canAddMore else {
            errorMessage = "You can add up to \(maxUserAdds) items."
            return
        }
        let codeKey = d.alpha2Code.uppercased()
        let dupInUser = userAddedCountries.contains { $0.alpha2Code.uppercased() == codeKey }
        let dupInAPI  = countries.contains { $0.alpha2Code.uppercased() == codeKey }
        guard !dupInUser && !dupInAPI else {
            errorMessage = "This country already exists in the list."
            return
        }

        let model = CountryEntity(
            name: d.name,
            alpha2Code: d.alpha2Code,
            flagPNG: d.flagPNG,
            capital: d.capital,
            currencyCode: d.currencyCode,
            currencyName: d.currencyName,
            currencySymbol: d.currencySymbol
        )
        
        userAddedCountries.append(model)
        infoMessage = "Added \(d.name). You can add \(remainingAddSlots) more."
    }
}
