//
//  VendorSessionManager.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//
import Foundation


public final class VendorSessionManager {

    public static let shared = VendorSessionManager()
    private init() {}

    private let tokenKey = "auth.token"

    /// Current in-memory token snapshot (thread-safe via serial queue).
    private let queue = DispatchQueue(label: "vendor.session.queue", qos: .userInitiated)
    private var _token: String?

    /// Returns the current token if available.
    public var token: String? {
        queue.sync {
            if _token == nil {
                _token = LocalStore.get(tokenKey, kind: .secure)
            }
            return _token
        }
    }

    /// Saves token securely and broadcasts login event.
    public func setToken(_ newToken: String) {
        queue.sync {
            _token = newToken
            _ = LocalStore.set(newToken, for: tokenKey, kind: .secure)
        }
        NotificationCenter.default.post(name: .vendorDidLogin, object: nil)
    }

    /// Clears token and user-local state, broadcasts logout event.
    public func logout(clearDefaults: Bool = true) {
        queue.sync {
            _token = nil
            _ = LocalStore.set(nil, for: tokenKey, kind: .secure)
        }
        if clearDefaults {
            // Optional: clear just app-owned keys; avoid nuking user settings unintentionally.
            DefaultsStore.remove(.vendorProfile)
            DefaultsStore.remove(.onboardingSeen)
        }
        NotificationCenter.default.post(name: .vendorDidLogout, object: nil)
    }

    /// For debugging only.
    public func forceReplaceToken(_ token: String?) {
        queue.sync {
            _token = token
            _ = LocalStore.set(token, for: tokenKey, kind: .secure)
        }
    }
}

public extension Notification.Name {
    static let vendorDidLogin  = Notification.Name("vendor.session.login")
    static let vendorDidLogout = Notification.Name("vendor.session.logout")
}
