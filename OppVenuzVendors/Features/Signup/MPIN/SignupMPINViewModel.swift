//
//  SignupMPINViewModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import Combine
import SwiftUI
import Foundation

@MainActor
final class SignupMPINViewModel: ObservableObject {
    
    @Published var mpin: String = ""
    @Published var confirmMPIN: String = ""
    
    var isValid: Bool {
        mpin.count == 6 && confirmMPIN == mpin
    }
    
    func updateMPIN(_ value: String) {
        mpin = String(value.prefix(6).filter { $0.isNumber })
    }
    
    func updateConfirmMPIN(_ value: String) {
        confirmMPIN = String(value.prefix(6).filter { $0.isNumber })
    }
    
    func saveDraft() {
        // Save in temporary step draft
        let stepDraft = SignupMPINDraft.shared
        stepDraft.mpin = mpin
        // ALSO save into the real SignupDraft for the final signup API
        let signupDraft = SignupDraft.shared
        signupDraft.set(\.mpin, mpin)
        signupDraft.save()
    }

}
