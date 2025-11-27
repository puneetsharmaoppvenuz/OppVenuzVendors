//
//  GooglePlacesPickerView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 17/11/25.
//

import SwiftUI
import GooglePlaces
import CoreLocation

struct SimplePlace {
    let name: String
    let formattedAddress: String?
    let coordinate: CLLocationCoordinate2D
    let postalCode: String?
    let city: String?
    let state: String?
    let streetLine: String?
}

struct GooglePlacesPickerView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    /// City center (lat/lng) to restrict addresses around
    var biasCenter: CLLocationCoordinate2D?
    
    /// Hard radius limit in KM (e.g. 30)
    var biasRadiusInKm: Double = 30
    
    /// Callback when a valid place is selected (within radius)
    var onPlaceSelected: (SimplePlace) -> Void
    
    // MARK: - UIViewControllerRepresentable
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteVC = GMSAutocompleteViewController()
        autocompleteVC.delegate = context.coordinator
        
        // Which fields we need
        autocompleteVC.placeFields = [
            .name,
            .formattedAddress,
            .coordinate,
            .addressComponents
        ]
        
        // 🔴 IMPORTANT: use filter.locationRestriction instead of autocompleteBounds
        if let center = biasCenter {
            let radiusInMeters = min(biasRadiusInKm * 1000.0, 50_000.0) // API max ~50km
            
            let filter = GMSAutocompleteFilter()
            filter.locationRestriction = GMSPlaceCircularLocationOption(center, radiusInMeters)
            autocompleteVC.autocompleteFilter = filter
        }
        
        return autocompleteVC
    }
    
    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController,
                                context: Context) {
        // nothing to update dynamically
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        let parent: GooglePlacesPickerView
        init(_ parent: GooglePlacesPickerView) { self.parent = parent }
        
        // helper to pull a component by type
        private func component(_ type: String, from place: GMSPlace) -> String? {
            return place.addressComponents?
                .first(where: { $0.types.contains(type) })?
                .name
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController,
                            didAutocompleteWith place: GMSPlace) {
            
            // radius check (already there)
            if let center = parent.biasCenter {
                let cityLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
                let placeLoc = CLLocation(latitude: place.coordinate.latitude,
                                          longitude: place.coordinate.longitude)
                let distanceKm = cityLoc.distance(from: placeLoc) / 1000.0
                if distanceKm > parent.biasRadiusInKm {
                    let alert = UIAlertController(
                        title: "Address not Available",
                        message: "Sorry, oppvenuz service is only available in the selected city limited area. Please update the city if your address belongs to another city or contact to Oppvenuz sales person.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(alert, animated: true)
                    return
                }
            }
            
            // 🔹 NEW: parse address components
            let postalCode = component("postal_code", from: place)
            let city = component("locality", from: place)
            ?? component("sublocality_level_1", from: place)
            let state = component("administrative_area_level_1", from: place)
            
            let streetNumber = component("street_number", from: place)
            let route = component("route", from: place)
            let streetLine: String?
            if let num = streetNumber, let rt = route {
                streetLine = "\(num) \(rt)"
            } else {
                streetLine = route
            }
            
            let simplePlace = SimplePlace(
                name: place.name ?? "",
                formattedAddress: place.formattedAddress,
                coordinate: place.coordinate,
                postalCode: postalCode,
                city: city,
                state: state,
                streetLine: streetLine
            )
            
            parent.onPlaceSelected(simplePlace)
            parent.isPresented = false
            viewController.dismiss(animated: true)
        }
        
        // User cancelled
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.isPresented = false
            viewController.dismiss(animated: true)
        }
        
        // Error
        func viewController(_ viewController: GMSAutocompleteViewController,
                            didFailAutocompleteWithError error: Error) {
            print("Autocomplete error: \(error.localizedDescription)")
            parent.isPresented = false
            viewController.dismiss(animated: true)
        }
    }
}
