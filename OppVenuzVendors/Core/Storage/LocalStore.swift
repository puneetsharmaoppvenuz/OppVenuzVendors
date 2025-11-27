//
//  LocalStore.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public enum LocalStore {
    
    public enum StorageKind {
        case secure
        case standard
    }
    
    // MARK: - Public API
    
    /// Save a String value (or nil to remove).
    @discardableResult
    public static func set(_ value: String?, for key: String, kind: StorageKind) -> Bool {
        switch kind {
        case .secure:
            if let v = value { return KeychainStore.save(v, for: key) }
            else { return KeychainStore.delete(key) }
            
        case .standard:
            return setStandard(value, for: key)
        }
    }
    
    /// Read a String value.
    public static func get(_ key: String, kind: StorageKind) -> String? {
        switch kind {
        case .secure:
            return KeychainStore.read(key)
            
        case .standard:
            return getStandard(key)
        }
    }
    
    /// Clear all app-local data (defaults + generic password items in Keychain).
    public static func clearAll() {
        KeychainStore.clearAll()
        let defaults = UserDefaults.standard
        for (k, _) in defaults.dictionaryRepresentation() {
            defaults.removeObject(forKey: k)
        }
    }
    
    // MARK: - Internals (standard storage)
    
    /// Try to use DefaultsStore typed API when possible, else fallback to raw UserDefaults.
    @discardableResult
    private static func setStandard(_ value: String?, for key: String) -> Bool {
        if let typedKey = DefaultsStore.Key(rawValue: key) {
            return DefaultsStore.setString(value, for: typedKey)
        } else {
            let d = UserDefaults.standard
            if let v = value { d.set(v, forKey: key) }
            else { d.removeObject(forKey: key) }
            return true
        }
    }
    
    private static func getStandard(_ key: String) -> String? {
        if let typedKey = DefaultsStore.Key(rawValue: key) {
            return DefaultsStore.getString(typedKey)
        } else {
            return UserDefaults.standard.string(forKey: key)
        }
    }
}
