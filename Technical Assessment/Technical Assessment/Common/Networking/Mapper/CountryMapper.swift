//
//  CountryMapper.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation
struct CountryListResponse: Decodable {
    let name: String
    let alpha2Code: String
    let capital: String?
    let currencies: [CurrencyDTO]?
    struct CurrencyDTO: Decodable {
        let code: String?
        let name: String?
        let symbol: String?
    }
}

struct CountryEntity: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let alpha2Code: String
    let flagPNG: String
    let capital: String?
    let currencyCode: String?
    let currencyName: String?
    let currencySymbol: String?
}

struct CountryMapper {
    func fromRespToDto(_ resp: CountryListResponse) -> CountryEntity {
        let codeLower = resp.alpha2Code.lowercased()
        let png = "https://flagcdn.com/w80/\(codeLower).png"
        let cur = resp.currencies?.first
        return CountryEntity(
            name: resp.name,
            alpha2Code: resp.alpha2Code,
            flagPNG: png,
            capital: resp.capital,
            currencyCode: cur?.code,
            currencyName: cur?.name,
            currencySymbol: cur?.symbol
        )
    }
}

struct CountryDraft {
    var name: String
    var alpha2Code: String
    var flagPNG: String
    var capital: String?
    var currencyCode: String?
    var currencyName: String?
    var currencySymbol: String?

    func trimmed() -> CountryDraft {
        CountryDraft(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            alpha2Code: alpha2Code.trimmingCharacters(in: .whitespacesAndNewlines),
            flagPNG: flagPNG.trimmingCharacters(in: .whitespacesAndNewlines),
            capital: capital?.trimmedOrNil,
            currencyCode: currencyCode?.trimmedOrNil,
            currencyName: currencyName?.trimmedOrNil,
            currencySymbol: currencySymbol?.trimmedOrNil
        )
    }
}

private extension String {
    var trimmedOrNil: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
