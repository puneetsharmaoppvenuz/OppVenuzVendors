//
//  SignupBusinessLocationViewModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import Combine
import CoreLocation
import Foundation
import SwiftUI

// MARK: - Models
struct SignupState: Identifiable, Hashable {
    let id: Int
    let name: String
}

struct SignupCity: Identifiable, Hashable {
    let id: Int
    let stateId: Int
    let name: String
    let lat: Double
    let long: Double
}

// MARK: - ViewModel
@MainActor
final class SignupBusinessLocationViewModel: ObservableObject {
    
    // MARK: - Master data (from BaseAPI)
    
    /// All states from BaseAPI
    @Published var allStates: [SignupState] = []
    
    /// All cities from BaseAPI, but flattened: each carries its stateId
    @Published var allCities: [SignupCity] = []
    
    /// Cities for the currently selected state only
    @Published var filteredCities: [SignupCity] = []
    
    // MARK: - Selections
    
    @Published var selectedState: SignupState? = nil {
        didSet { updateCityFilterForSelectedState() }
    }
    
    @Published var selectedCity: SignupCity? = nil
    
    // MARK: - Address fields
    
    @Published var locationOrPincode: String = ""
    @Published var house: String = ""
    @Published var street: String = ""
    @Published var cityText: String = ""
    @Published var stateText: String = ""
    @Published var pincode: String = ""
    
    // MARK: - Coordinates
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    @Published var isAddressLockedFromPlaces: Bool = false
    // MARK: - Init
    
    init() {
        loadMasterData()
        loadDraft()
    }
    
    // MARK: - Validation
    
    var canContinue: Bool {
        selectedState != nil &&
        selectedCity != nil &&
        !street.trimmed.isEmpty &&
        !cityText.trimmed.isEmpty &&
        !stateText.trimmed.isEmpty &&
        !pincode.trimmed.isEmpty
    }
    
    // MARK: - Public actions
    func saveDraft() {
        
        // 1. Build full address
        let addressComponents = [
            house.trimmed,
            street.trimmed,
            cityText.trimmed,
            stateText.trimmed
        ].filter { !$0.isEmpty }
        
        let fullAddress = addressComponents.joined(separator: ", ")
        
        // pincode: prefer pincode, fallback locationOrPincode
        let effectivePincode: String? = {
            if !pincode.trimmed.isEmpty { return pincode.trimmed }
            if !locationOrPincode.trimmed.isEmpty { return locationOrPincode.trimmed }
            return nil
        }()
        
        // 2. Save into global SignupDraft
        let signup = SignupDraft.shared
        
        if let st = selectedState {
            signup.set(\.stateId, st.id)
            signup.set(\.stateName, st.name)
        }
        
        if let ct = selectedCity {
            signup.set(\.cityId, ct.id)
            signup.set(\.cityName, ct.name)
        }
        
        signup.set(\.addressLine, fullAddress)
        
        if let pc = effectivePincode {
            signup.set(\.pincode, pc)
        }
        
        // Coordinates formatted with 6 decimal places
        if let lat = latitude {
            let formatted = Double(String(format: "%.6f", lat))
            signup.set(\.latitude, formatted ?? lat)
        }
        if let lng = longitude {
            let formatted = Double(String(format: "%.6f", lng))
            signup.set(\.longitude, formatted ?? lng)
        }
        
        signup.save()
    }
    
    
    /// This will be called from Google Places integration once place is selected.
    func handleSelectedPlace(address: String,
                             street: String?,
                             city: String?,
                             state: String?,
                             pincode: String?,
                             lat: Double?,
                             lng: Double?) {
        locationOrPincode = address
        self.street = street ?? ""
        cityText = city ?? ""
        stateText = state ?? ""
        self.pincode = pincode ?? ""
        latitude = lat
        longitude = lng
    }
    
    
    // MARK: - Private helpers
    private func loadMasterData() {
        guard let envelope = BaseAPIService.cachedEnvelope(),
              let data = envelope.data else {
            allStates = []
            allCities = []
            filteredCities = []
            return
        }
        var states: [SignupState] = []
        var cities: [SignupCity] = []
        
        if let apiStates = data.states {
            for state in apiStates {
                let stateId = state.id
                let stateName = state.state_name
                
                let signupState = SignupState(id: stateId, name: stateName)
                states.append(signupState)
                
                // Flatten nested city array with stateId attached
                if let apiCities = state.cities {
                    for city in apiCities {
                        let cityId = city.id
                        let cityName = city.city_name
                        let cityLat = city.latitude
                        let cityLong = city.longitude
                        let signupCity = SignupCity(
                            id: cityId,
                            stateId: stateId,
                            name: cityName,
                            lat: cityLat,
                            long: cityLong
                        )
                        cities.append(signupCity)
                    }
                }
            }
        }
        
        allStates = states
        allCities = cities
        
        // According to your requirement:
        // If no state is selected, there should be NO city list.
        filteredCities = []
    }
    
    private func loadDraft() {
        let d = SignupLocationDraft.shared
        
        // Restore selected state
        if let stateId = d.stateId,
           let state = allStates.first(where: { $0.id == stateId }) {
            selectedState = state
        }
        
        // Once selectedState is set, city filter will run.
        // Restore selected city
        if let cityId = d.cityId,
           let city = allCities.first(where: { $0.id == cityId }) {
            selectedCity = city
        }
        
        locationOrPincode = d.locationOrPincode
        house = d.house
        street = d.street
        cityText = d.cityText
        stateText = d.stateText
        pincode = d.pincode
        latitude = d.latitude
        longitude = d.longitude
        
        // If we restored state, ensure cities are filtered for that state.
        if selectedState != nil {
            updateCityFilterForSelectedState()
        }
    }
    
    private func updateCityFilterForSelectedState() {
        // No state → no cities at all
        guard let state = selectedState else {
            filteredCities = []
            selectedCity = nil
            cityText = ""
            return
        }
        
        // Filter cities for this state
        filteredCities = allCities.filter { $0.stateId == state.id }
        
        // Reset city selection whenever state changes
        selectedCity = nil
        cityText = ""
    }
    
    // MARK: - Optional city center for biasing Google Places
    var cityCenterCoordinate: CLLocationCoordinate2D? {
        if let city = selectedCity {
            return CLLocationCoordinate2D(latitude: city.lat, longitude: city.long)
        }
        return nil
    }
    
    func clearAddressFromPlaces() {
        locationOrPincode = ""
        house = ""
        street = ""
        cityText = ""
        stateText = ""
        pincode = ""
        latitude = nil
        longitude = nil
        isAddressLockedFromPlaces = false
    }
    
}

// MARK: - Draft Model

final class SignupLocationDraft {
    static let shared = SignupLocationDraft()
    
    var stateId: Int?
    var stateName: String?
    
    var cityId: Int?
    var cityName: String?
    
    var locationOrPincode: String = ""
    var house: String = ""
    var street: String = ""
    var cityText: String = ""
    var stateText: String = ""
    var pincode: String = ""
    
    var latitude: Double?
    var longitude: Double?
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
