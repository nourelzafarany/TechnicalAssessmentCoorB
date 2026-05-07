//
//  CountryLocalStorageModel.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 07/05/2026.
//

import Foundation
import SwiftData

@Model
final class LocalCountryEntity {

    var name: String
    var alpha2Code: String
    var flagPNG: String
    var capital: String
    var currencyCode: String
    var currencyName: String
    var currencySymbol: String

    init(
        name: String,
        alpha2Code: String,
        flagPNG: String,
        capital: String,
        currencyCode: String,
        currencyName: String,
        currencySymbol: String
    ) {
        self.name = name
        self.alpha2Code = alpha2Code
        self.flagPNG = flagPNG
        self.capital = capital
        self.currencyCode = currencyCode
        self.currencyName = currencyName
        self.currencySymbol = currencySymbol
    }
}
