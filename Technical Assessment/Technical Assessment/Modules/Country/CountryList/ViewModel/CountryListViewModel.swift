//
//  CountryListViewModel.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation
import Combine

enum Status { case idle, loading, loaded, error(String) }

class CountryListViewModel: ObservableObject {

    @Published var status: Status = .idle
    @Published var countries: [CountryEntity] = []
    @Published var searchWord: String = ""
    var userAddedCountries: [CountryEntity] = []
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    let maxUserAdds = 5
    var remainingAddSlots: Int { maxUserAdds - userAddedCountries.count }
    var canAddMore: Bool { remainingAddSlots > 0 }
    
    private let getCountries: GetCountryListUseCase
    private let userCountryService: UserCountryServiceProtocol?
    private var currentTask: Task<Void, Never>?

    init(getCountries: GetCountryListUseCase, userCountryService: UserCountryServiceProtocol?) {
        self.getCountries = getCountries
        self.userCountryService = userCountryService
    }

    func onAppear() {
        if case .idle = status {
            Task { await load(force: false) }
        }
    }

    func refresh() async {
        startLoading(force: true)
    }

    func onDisappear() {
        currentTask?.cancel()
        currentTask = nil
    }

    private func startLoading(force: Bool) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.load(force: force)
        }
    }
    
    func load(force: Bool = false) async {
        status = .loading
        async let listTask: [CountryEntity] = getCountries.execute(forceRefresh: force)
        async let userCodeTask: String? = userCountryService?.getUserCountryCode()
        
        do {
            var list = try await listTask
//            let preferred = (await userCodeTask)?.uppercased()
//            ?? Locale.current.region?.identifier.uppercased()
            
//            if let idx = list.firstIndex(where: { $0.alpha2Code.uppercased() == preferred }) {
//                let fav = list.remove(at: idx)
//                list.insert(fav, at: 0)
//            }
            countries = list
            status = .loaded
        } catch {
            status = .error(error.localizedDescription)
        }
    }

    deinit {
        currentTask?.cancel()
    }
}
