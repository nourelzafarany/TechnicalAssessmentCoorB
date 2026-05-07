//
//  Technical_AssessmentApp.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import SwiftUI
import CoreData

@main
struct Technical_AssessmentApp: App {
    var body: some Scene {
        WindowGroup {
                let remote  = CountryListRemoteDataSource()
                let local   = CountryListLocalDataSource()
                let mapper  = CountryMapper()
                let repo    = CountryListRepository(remote: remote, local: local, mapper: mapper)
                let useCase = GetCountryListUseCase(repo: repo)
                let userCountryService = UserCountryService()
                let vm      = CountryListViewModel(getCountries: useCase, userCountryService: userCountryService)
                NavigationView {
                    CountryListView(vm: vm)
                }
        }
    }
}
