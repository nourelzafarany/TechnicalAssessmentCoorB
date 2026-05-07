//
//  CountryDetailsView.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 07/05/2026.
//

import SwiftUI

struct CountryDetailsView: View {
    var vm: CountryDetailViewModel
    var body: some View {
        List {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: vm.country?.flagPNG ?? "")) { $0.resizable() } placeholder: { ProgressView() }
                    .frame(width: 96, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.country?.name ?? "").font(.title3).bold()
                    Text(vm.country?.alpha2Code ?? "").foregroundStyle(.secondary)
                }
            }
            if let cap = vm.country?.capital, !cap.isEmpty {
                LabeledContent("Capital", value: cap)
            }
            if vm.country?.currencyCode != nil || vm.country?.currencyName != nil {
                LabeledContent("Currency") {
                    VStack(alignment: .leading) {
                        if let code = vm.country?.currencyCode { Text("Code: \(code)") }
                        if let name = vm.country?.currencyName { Text("Name: \(name)") }
                        if let sym  = vm.country?.currencySymbol { Text("Symbol: \(sym)") }
                    }
                }
            }
        }
        .navigationTitle("Details")
    }
}
