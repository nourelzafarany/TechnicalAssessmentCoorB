//
//  AddView.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import SwiftUI

struct AddSheetView: View {
    
    @State private var newName = ""
    @State private var newCode = ""
    @State private var newFlagURL = ""
    @State private var capital = ""
    @State private var currencyCode = ""
    @State private var currencyName = ""
    @State private var currencySymbol = ""
    @State private var showingAddSheet = false
    
    var userAddedCountries: Int
    var maxUserAdds: Int
    var errorMessage: String? 
    var canAddMore: Bool
    let addCustomCountry: (_ countryDraft: CountryDraft) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("New country") {
                    TextField("Name (e.g., Egypt)", text: $newName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Code (e.g., EG)", text: $newCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                    
                    TextField("Flag URL (PNG)", text: $newFlagURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    
                    TextField("Capital", text: $capital)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Currancy Code", text: $currencyCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                    
                    TextField("Currency Name", text: $currencyName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Currency Symbol", text: $currencySymbol)
                        .textInputAutocapitalization(.characters)
                }
                Section {
                    Text("\(userAddedCountries)/\(maxUserAdds) added")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Country")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addCustomCountry(
                            CountryDraft(
                                name: newName,
                                alpha2Code: newCode,
                                flagPNG: newFlagURL,
                                capital: capital,
                                currencyCode: currencyCode,
                                currencyName: currencyName,
                                currencySymbol: currencySymbol
                            )
                        )
                        if errorMessage == nil {
                            showingAddSheet = false
                        }
                    }
                    .disabled(
                        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        newCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        newFlagURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        !canAddMore
                    )
                }
            }
        }
    }
}
