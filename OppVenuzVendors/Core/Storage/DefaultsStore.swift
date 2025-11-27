//
//  DefaultsStore.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//
import Foundation

public enum DefaultsStore {
    private static let defaults = UserDefaults.standard
    
    public enum Key: String {
        case authToken
        case onboardingSeen
        case vendorProfile
        case themeMode
        case baseAPI
        case onboardingGIF
    }
    
    // MARK: - Primitives
    
    @discardableResult
    public static func setString(_ value: String?, for key: Key) -> Bool {
        if let v = value { defaults.set(v, forKey: key.rawValue) }
        else { defaults.removeObject(forKey: key.rawValue) }
        return true
    }
    
    public static func getString(_ key: Key) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    @discardableResult
    public static func setBool(_ value: Bool?, for key: Key) -> Bool {
        if let v = value { defaults.set(v, forKey: key.rawValue) }
        else { defaults.removeObject(forKey: key.rawValue) }
        return true
    }
    
    public static func getBool(_ key: Key) -> Bool? {
        defaults.object(forKey: key.rawValue) as? Bool
    }
    
    @discardableResult
    public static func setInt(_ value: Int?, for key: Key) -> Bool {
        if let v = value { defaults.set(v, forKey: key.rawValue) }
        else { defaults.removeObject(forKey: key.rawValue) }
        return true
    }
    
    public static func getInt(_ key: Key) -> Int? {
        (defaults.object(forKey: key.rawValue) as? NSNumber)?.intValue
    }
    
    @discardableResult
    public static func setData(_ value: Data?, for key: Key) -> Bool {
        if let v = value { defaults.set(v, forKey: key.rawValue) }
        else { defaults.removeObject(forKey: key.rawValue) }
        return true
    }
    
    public static func getData(_ key: Key) -> Data? {
        defaults.data(forKey: key.rawValue)
    }
    
    // MARK: - Codable
    
    @discardableResult
    public static func setCodable<T: Codable>(_ value: T?, for key: Key) -> Bool {
        if let value = value {
            do {
                let data = try JSONEncoder().encode(value)
                defaults.set(data, forKey: key.rawValue)
                return true
            } catch {
                print("⚠️ DefaultsStore encode failed: \(error)")
                return false
            }
        } else {
            defaults.removeObject(forKey: key.rawValue)
            return true
        }
    }
    
    public static func getCodable<T: Codable>(_ type: T.Type, for key: Key) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("⚠️ DefaultsStore decode failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Remove
    
    public static func remove(_ key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
