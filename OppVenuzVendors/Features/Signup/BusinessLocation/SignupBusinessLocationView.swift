//
//  SignupLoca.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import SwiftUI
import GooglePlaces
import CoreLocation

struct SignupBusinessLocationView: View {
    
    @StateObject private var viewModel = SignupBusinessLocationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onContinue: (() -> Void)? = nil
    
    @State private var isStatePickerPresented = false
    @State private var isCityPickerPresented = false
    @State private var isPlacesPickerPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    progressHeader
                    
                    Image("signup3")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .padding(.top, 8)
                    
                    Text("Add Your Business Location")
                        .font(RobotoFont.bold(20))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                    
                    stateSection
                    citySection
                    locationButtonSection
                    houseSection
                    streetSection
                    cityFieldSection
                    stateFieldSection
                    pincodeSection
                    
                    Button {
                        viewModel.saveDraft()
                        onContinue?()
                    } label: {
                        Text("Continue")
                            .font(RobotoFont.medium(17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(
                        viewModel.canContinue
                        ? LinearGradient(
                            colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .disabled(!viewModel.canContinue)
                }
                .padding(.horizontal, 24)
            }
            .sheet(isPresented: $isStatePickerPresented) {
                StatePickerSheet(
                    states: viewModel.allStates,
                    selected: viewModel.selectedState
                ) { state in
                    viewModel.selectedState = state
                    viewModel.stateText = state.name
                    viewModel.clearAddressFromPlaces()
                }
            }
            .sheet(isPresented: $isCityPickerPresented) {
                CityPickerSheet(
                    cities: viewModel.filteredCities,
                    selected: viewModel.selectedCity
                ) { city in
                    viewModel.selectedCity = city
                    viewModel.cityText = city.name
                    viewModel.clearAddressFromPlaces()
                }
            }
            .sheet(isPresented: $isPlacesPickerPresented) {
                GooglePlacesPickerView(
                    isPresented: $isPlacesPickerPresented,
                    biasCenter: viewModel.cityCenterCoordinate,
                    biasRadiusInKm: 50
                ) { place in
                    handlePlaceSelection(place)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Google Places → ViewModel
    private func handlePlaceSelection(_ place: SimplePlace) {
        // We already know city/state from the selected dropdowns
        let cityName = viewModel.selectedCity?.name
        let stateName = viewModel.selectedState?.name

        // Always prefer the postalCode coming from Google
        let pin = place.postalCode

        let address = place.formattedAddress ?? place.name
        let street = place.streetLine ?? place.name

        viewModel.handleSelectedPlace(
            address: address,
            street: street,
            city: cityName,
            state: stateName,
            pincode: pin,
            lat: place.coordinate.latitude,
            lng: place.coordinate.longitude
        )

        // lock all address fields
        viewModel.isAddressLockedFromPlaces = true
    }

    
    // MARK: - Header
    
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("2/3")
                .font(RobotoFont.medium(12))
                .foregroundColor(.primary)
            
            HStack(spacing: 6) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - State section
    
    private var stateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Select State*")
                .font(RobotoFont.medium(15))
            
            Button {
                isStatePickerPresented = true
            } label: {
                HStack {
                    Text(viewModel.selectedState?.name ?? "Select State")
                        .font(RobotoFont.regular(14))
                        .foregroundColor(
                            viewModel.selectedState == nil ? .secondary : .primary
                        )
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - City section
    
    private var citySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Select City*")
                .font(RobotoFont.medium(15))
            
            Button {
                // Only allow if we actually have cities for the selected state
                if !viewModel.filteredCities.isEmpty {
                    isCityPickerPresented = true
                }
            } label: {
                HStack {
                    Text(viewModel.selectedCity?.name ?? "Select City")
                        .font(RobotoFont.regular(14))
                        .foregroundColor(
                            viewModel.selectedCity == nil ? .secondary : .primary
                        )
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(
                            viewModel.filteredCities.isEmpty ? .gray.opacity(0.4) : .secondary
                        )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Location button (Places)
    
    private var locationButtonSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Enter your Location or Pincode")
                .font(RobotoFont.medium(15))
            
            Button {
                isPlacesPickerPresented = true
            } label: {
                HStack {
                    Text(
                        viewModel.locationOrPincode.isEmpty
                        ? "Enter Location or Pincode"
                        : viewModel.locationOrPincode
                    )
                    .font(RobotoFont.regular(14))
                    .foregroundColor(
                        viewModel.locationOrPincode.isEmpty ? .secondary : .primary
                    )
                    .lineLimit(1)
                    .truncationMode(.tail)
                    
                    Spacer()
                    Image(systemName: "location.viewfinder")
                        .foregroundColor(Color(hex: "#5A69FC"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Text fields
    
    private var houseSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("House/ Apartment/ Shop (Optional)")
                .font(RobotoFont.medium(15))
            
            TextField("House/ Apartment/ Shop (Optional)", text: $viewModel.house)
                .font(RobotoFont.regular(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var streetSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Street")
                .font(RobotoFont.medium(15))
            
            TextField("Street", text: $viewModel.street)
                .font(RobotoFont.regular(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .disabled(viewModel.isAddressLockedFromPlaces)
        }
    }
    
    private var cityFieldSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("City")
                .font(RobotoFont.medium(15))
            
            TextField("City", text: $viewModel.cityText)
                .font(RobotoFont.regular(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .disabled(viewModel.isAddressLockedFromPlaces)
        }
    }
    
    private var stateFieldSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("State")
                .font(RobotoFont.medium(15))
            
            TextField("State", text: $viewModel.stateText)
                .font(RobotoFont.regular(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .disabled(viewModel.isAddressLockedFromPlaces)
        }
    }
    
    private var pincodeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pin code")
                .font(RobotoFont.medium(15))
            
            TextField("Pincode (If not Auto Fetched)", text: $viewModel.pincode)
                .font(RobotoFont.regular(14))
                .keyboardType(.numberPad)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .disabled(viewModel.isAddressLockedFromPlaces)
        }
    }
}

// MARK: - Bottom sheet pickers

private struct StatePickerSheet: View {
    let states: [SignupState]
    let selected: SignupState?
    let onSelect: (SignupState) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(states) { state in
                Button {
                    onSelect(state)
                    dismiss()
                } label: {
                    HStack {
                        Text(state.name)
                            .font(RobotoFont.regular(15))
                            .foregroundColor(.black)
                        Spacer()
                        if state.id == selected?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "#5A69FC"))
                        }
                    }
                }
            }
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CityPickerSheet: View {
    let cities: [SignupCity]
    let selected: SignupCity?
    let onSelect: (SignupCity) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(cities) { city in
                Button {
                    onSelect(city)
                    dismiss()
                } label: {
                    HStack {
                        Text(city.name)
                            .font(RobotoFont.regular(15))
                        Spacer()
                        if city.id == selected?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "#5A69FC"))
                        }
                    }
                }
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
