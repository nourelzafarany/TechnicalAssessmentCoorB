//
//  CountriesListView.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import SwiftUI

struct CountryListView: View {
    @StateObject var vm: CountryListViewModel
    
    @State private var isSearchPresented = false
    @State private var showingAddSheet = false
    
    var body: some View {
        Group {
            ListView(filteredCountries: vm.filteredCountries, status: vm.status, onRefresh: vm.refresh, onDelete: vm.delete)
        }
        .navigationTitle("Countries")
        .accessibilityIdentifier("countries.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if case .loaded = vm.status, vm.canAddMore {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Country")
                }
            }
        }
        .searchable(
            text: $vm.searchWord,
            isPresented: $isSearchPresented,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search countries"
        )
        .onAppear {
            vm.onAppear()
            isSearchPresented = false
        }
        .onDisappear {
            vm.onDisappear()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddSheetView(userAddedCountries: vm.userAddedCountries.count,
                         maxUserAdds: vm.maxUserAdds,
                         canAddMore: vm.canAddMore,
                         addCustomCountry: vm.addCustomCountry)
            .presentationDetents([.large])
        }
        .alert("Notice",
               isPresented: .constant(vm.errorMessage != nil || vm.infoMessage != nil),
               actions: {
            Button("OK") {
                vm.errorMessage = nil
                vm.infoMessage = nil
            }
        }, message: {
            Text(vm.errorMessage ?? vm.infoMessage ?? "")
        })
    }
}

//#Preview {
//    CountryListView()
//}
