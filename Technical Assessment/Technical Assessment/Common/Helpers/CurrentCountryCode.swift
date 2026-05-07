//
//  CurrentCountryCode.swift
//  Technical Assessment
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
protocol UserCountryServiceProtocol {
    func getUserCountryCode() async -> String?
}

final class UserCountryService: NSObject, CLLocationManagerDelegate, UserCountryServiceProtocol {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<String?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func getUserCountryCode() async -> String? {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            return Locale.current.region?.identifier
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return await withCheckedContinuation { cont in
                self.continuation = cont
            }
        default:
            break
        }
        manager.requestLocation()
        return await withCheckedContinuation { cont in
            self.continuation = cont
        }
    }
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            finish(Locale.current.region?.identifier)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            finish(Locale.current.region?.identifier)
            return
        }
        Task {
            let code = await reverseGeocodeCountryCode(for: loc)
            finish(code ?? Locale.current.region?.identifier)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(Locale.current.region?.identifier)
    }

    private func finish(_ code: String?) {
        continuation?.resume(returning: code)
        continuation = nil
    }
    
    private func reverseGeocodeCountryCode(for location: CLLocation) async -> String? {
        return await withCheckedContinuation { cont in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                cont.resume(returning: placemarks?.first?.isoCountryCode)
            }
        }
    }
}
