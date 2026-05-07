//
//  CountryListLocalDataSource.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation
import SwiftData
protocol CountryListLocalDataSourceProtocol {
    func loadCountries() throws -> [LocalCountryEntity]
    func saveCountries(_ countries: [LocalCountryEntity]) throws
    func getLastUpdatedDate() -> Date?
}


// MARK: - File-based implementation
struct CountryListLocalDataSource: CountryListLocalDataSourceProtocol {
    private let context: ModelContext
    private let lastUpdatedKey = "countries_last_updated"
    
    init() {
        do {
            let container = try ModelContainer(for: LocalCountryEntity.self)
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create SwiftData container")
        }
    }
    
    func saveCountries(_ countries: [LocalCountryEntity]) throws {
        countries.forEach {
            context.insert($0)
        }
        try context.save()
        saveLastUpdatedDate()
    }
    
    func loadCountries() throws -> [LocalCountryEntity] {
        
        let descriptor = FetchDescriptor<LocalCountryEntity>(
            sortBy: [
                SortDescriptor(\.name)
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func hasCachedCountries() -> Bool {
        do {
            let countries = try loadCountries()
            return !countries.isEmpty
        } catch {
            return false
        }
    }
    
    private func saveLastUpdatedDate() {
        UserDefaults.standard.set(
            Date(),
            forKey: lastUpdatedKey
        )
    }
    func getLastUpdatedDate() -> Date? {
        
        UserDefaults.standard.object(
            forKey: lastUpdatedKey
        ) as? Date
    }
}
