//
//  TokenStore.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public final class TokenStore {
    public static let shared = TokenStore()
    private init() {}

    public var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "auth.token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "auth.token") }
    }
}
