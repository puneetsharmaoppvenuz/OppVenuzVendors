//
//  Signupplocievm.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 25/11/25.
//

import Foundation
import Combine

final class SignupPoliciesViewModel: ObservableObject {
    
    struct PolicyItem: Identifiable, Equatable {
        let id: Int
        let title: String
        let content: String
        let slug: String
        var isChecked: Bool
    }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var items: [PolicyItem] = []
    @Published var selectedItem: PolicyItem? = nil
    @Published private(set) var isContinueEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPolicies()
        setupBindings()
    }
    
    private func setupBindings() {
        $items
            .map { $0.allSatisfy { $0.isChecked } }
            .assign(to: &$isContinueEnabled)
    }
    
    private func loadPolicies() {
        guard let terms = BaseAPIService.cachedEnvelope()?.data?.terms_and_conditions else {
#if DEBUG
            print("SignupPoliciesViewModel: no terms_and_conditions in BaseAPI")
#endif
            items = []
            return
        }
        
        items = terms.map {
            PolicyItem(
                id: $0.id,
                title: $0.title,
                content: $0.content,
                slug: $0.slug,
                isChecked: false
            )
        }
    }
    
    func toggle(_ item: PolicyItem) {
        guard let index = items.firstIndex(of: item) else { return }
        items[index].isChecked.toggle()
    }
    
    func openDetail(_ item: PolicyItem) {
        selectedItem = item
    }
    
    func closeDetail() {
        selectedItem = nil
    }
    
    // MARK: - Final signup API
    
    @MainActor
    func performSignup() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let draft = SignupDraft.shared
        let body = FinalSignupRequest.fromDraft(draft)
        
        do {
            let request = try APIRequestFactory.make(.completeSignup(body: body))
            let response: SignupResponseEnvelope = try await NetworkManager.shared
                .requestJSON(request, decode: SignupResponseEnvelope.self)
            
            guard response.status ?? true, let profile = response.data else {
                let msg = response.message ?? "Signup failed."
                errorMessage = msg
                isLoading = false
                return false
            }
            
            // Save token + profile locally
            if let token = profile.access, !token.isEmpty {
                VendorSessionManager.shared.setToken(token)
                DefaultsStore.setString(token, for: .authToken)
            }
            
            DefaultsStore.setCodable(profile, for: .vendorProfile)
            
            // Clear draft after success
            SignupDraft.shared.clear()
            
            isLoading = false
            return true
        } catch {
#if DEBUG
            print("performSignup error: \(error)")
#endif
            errorMessage = "Unable to complete signup. Please try again."
            isLoading = false
            return false
        }
    }
}
