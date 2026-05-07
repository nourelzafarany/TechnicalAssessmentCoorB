//
//  ListView.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import SwiftUI

struct ListView: View {
    let filteredCountries: [CountryEntity]
    var status: Status
    let onRefresh: () async -> Void
    let onDelete: (_ country: CountryEntity) -> Void
    
    var body: some View {
        switch status {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            List(filteredCountries) { country in
                NavigationLink {
                    CountryDetailsView(
                        vm: CountryDetailViewModel(country: country)
                    )
                } label: {
                    HStack {
                        AsyncImage(url: URL(string: country.flagPNG)) { img in
                            img.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text(country.name)
                    }.accessibilityIdentifier("countries.row.\(country.alpha2Code)")
                        .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete(country)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .accessibilityIdentifier("countries.list")
            .listStyle(.plain)
            .refreshable { await onRefresh()
            }
        case .error(let message):
            VStack {
                Text("Error: \(message)")
                Button("Retry") { Task { await onRefresh() } }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
