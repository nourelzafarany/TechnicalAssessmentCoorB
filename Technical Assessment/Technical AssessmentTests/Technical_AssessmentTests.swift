//
//  Technical_AssessmentTests.swift
//  Technical AssessmentTests
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Testing
@testable import Technical_Assessment

struct Technical_AssessmentTests {

    struct MockGetCountriesUseCaseOK: GetCountryListUseCaseProtocol {
        let items: [CountryEntity]
        func execute(forceRefresh: Bool) async throws -> [CountryEntity] { items }
    }

    struct MockGetCountriesUseCaseError: GetCountryListUseCaseProtocol {
        struct DummyError: Error {}
        func execute(forceRefresh: Bool) async throws -> [CountryEntity] { throw DummyError() }
    }

    struct MockUserCountryService: UserCountryServiceProtocol {
        let code: String?
        func getUserCountryCode() async -> String? { code }
    }

    // MARK: - Tests
    @MainActor
    struct CountriesListViewModelTests {

        // MARK: Helper factory
        private func makeVM(
            api: [CountryEntity],
            userCode: String? = nil
        ) -> CountryListViewModel {
            CountryListViewModel(
                getCountries: MockGetCountriesUseCaseOK(items: api),
                userCountryService: MockUserCountryService(code: userCode)
            )
        }

        // Test for the Top Country
        @Test
        func load_prefersUserCountryOnTop() async throws {
            let api = [
                CountryEntity(name: "France", alpha2Code: "FR", flagPNG: "fr", capital: "Paris", currencyCode: "EUR", currencyName: "Euro", currencySymbol: "€"),
                CountryEntity(name: "Egypt",  alpha2Code: "EG", flagPNG: "eg", capital: "Cairo", currencyCode: "EGP", currencyName: "Egyptian Pound", currencySymbol: "E£"),
                CountryEntity(name: "Japan",  alpha2Code: "JP", flagPNG: "jp", capital: "Tokyo", currencyCode: "JPY", currencyName: "Japanese Yen", currencySymbol: "¥")
            ]
            let vm = makeVM(api: api, userCode: "eg")

            vm.onAppear()
            try await Task.sleep(nanoseconds: 50_000_000)

            #expect({
                if case .loaded = vm.status { return true }
                return false
            }())
            #expect(vm.countries.first?.alpha2Code == "EG")
        }

        // Test case for added custom contries
        @Test
        func addCustomCountry_succeeds() async throws {
            let vm = makeVM(api: [])

            vm.addCustomCountry(CountryDraft(
                name: "Testland",
                alpha2Code: "TL",
                flagPNG: "https://example.com/tl.png",
                capital: "Test City",
                currencyCode: "TLR",
                currencyName: "Test Lira",
                currencySymbol: "₺"
            ))
            #expect(vm.userAddedCountries.count == 1)
            #expect(vm.errorMessage == nil)
            #expect(vm.userAddedCountries.first?.capital == "Test City")
        }

        // Test case for added custom contries not to be duplicate or already in the list
        @Test
        func addCustomCountry_rejectsDuplicateAcrossSources() async throws {
            let api = [
                CountryEntity(name: "Egypt", alpha2Code: "EG",
                             flagPNG: "eg", capital: nil,
                             currencyCode: nil, currencyName: nil, currencySymbol: nil)
            ]
            let vm = makeVM(api: api)
            await vm.load(force: false)
            vm.addCustomCountry(CountryDraft(
                name: "New Egypt",
                alpha2Code: "EG",
                flagPNG: "eg2",
                capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil
            ))
            #expect(vm.userAddedCountries.count == 0)
            #expect(vm.errorMessage == "This country already exists in the list.")
        }

        // Test case for added custom contries without exceeding the maximum number which is 5
        @Test
        func addCustomCountry_respectsMaxCapFive() async throws {
            let vm = makeVM(api: [])
            for i in 1...5 {
                vm.addCustomCountry(CountryDraft(
                    name: "C\(i)",
                    alpha2Code: "C\(i)",
                    flagPNG: "https://host/\(i).png",
                    capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil
                ))
            }
            #expect(vm.userAddedCountries.count == 5)
            vm.addCustomCountry(CountryDraft(
                name: "C6",
                alpha2Code: "C6",
                flagPNG: "https://host/6.png",
                capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil
            ))
            #expect(vm.userAddedCountries.count == 5)
            #expect(vm.errorMessage == "You can add up to 5 items.")
        }

        // Test case for removing country from the list.
        @Test
        func delete_removesFromUserAddedFirst() async throws {
            let vm = makeVM(api: [])

            vm.addCustomCountry(CountryDraft(
                name: "A", alpha2Code: "AA", flagPNG: "a.png",
                capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil
            ))

            let toDelete = try #require(vm.userAddedCountries.first)
            vm.delete(country: toDelete)

            #expect(vm.userAddedCountries.isEmpty)
        }

        // Test for Search
        @Test
        func search_matchesNameOnly() async throws {
            let api = [
                CountryEntity(name: "Egypt",  alpha2Code: "EG", flagPNG: "eg", capital: "Cairo", currencyCode: "EGP", currencyName: "Egyptian Pound", currencySymbol: "E£"),
                CountryEntity(name: "France", alpha2Code: "FR", flagPNG: "fr", capital: "Paris", currencyCode: "EUR", currencyName: "Euro",            currencySymbol: "€"),
                CountryEntity(name: "Finland",alpha2Code: "FI", flagPNG: "fi", capital: "Helsinki", currencyCode: "EUR", currencyName: "Euro",        currencySymbol: "€")
            ]
            let vm = makeVM(api: api)
            vm.onAppear()
            try await Task.sleep(nanoseconds: 50_000_000)

            vm.searchWord = "land"
            #expect(vm.filteredCountries.map(\.name) == ["Finland"])
            vm.searchWord = "fra"
            #expect(vm.filteredCountries.map(\.name) == ["France"])
            vm.searchWord = "cai"
            #expect(vm.filteredCountries.isEmpty)

            vm.searchWord = "eur"
            #expect(vm.filteredCountries.isEmpty)
        }

        @Test
        func search_emptyQueryReturnsAll() async throws {
            let api = [
                CountryEntity(name: "Egypt", alpha2Code: "EG", flagPNG: "eg", capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil),
                CountryEntity(name: "France", alpha2Code: "FR", flagPNG: "fr", capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil)
            ]
            let vm = makeVM(api: api)
            vm.onAppear()
            try await Task.sleep(nanoseconds: 50_000_000)

            vm.searchWord = ""
            #expect(vm.filteredCountries.count == 2)
        }

        @Test
        func search_isCaseInsensitiveOnName() async throws {
            let api = [
                CountryEntity(name: "Japan", alpha2Code: "JP", flagPNG: "jp", capital: nil, currencyCode: nil, currencyName: nil, currencySymbol: nil)
            ]
            let vm = makeVM(api: api)
            vm.onAppear()
            try await Task.sleep(nanoseconds: 50_000_000)

            vm.searchWord = "jaP"
            #expect(vm.filteredCountries.map(\.name) == ["Japan"])
        }
    }
}
