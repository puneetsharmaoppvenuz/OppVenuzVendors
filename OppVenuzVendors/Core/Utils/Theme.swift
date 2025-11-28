//
//  Theme.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 28/11/25.
//

import SwiftUI

// MARK: - App Colors

extension Color {
    // Background
    static let appBackground = Color(red: 245/255, green: 246/255, blue: 255/255)

    // Primary gradients
    static let primaryGradientStart = Color(red: 60/255, green: 32/255, blue: 195/255)
    static let primaryGradientEnd   = Color(red: 123/255, green: 44/255, blue: 191/255)

    static let rewardsGradientStart = Color(red: 117/255, green: 63/255, blue: 255/255)
    static let rewardsGradientEnd   = Color(red: 255/255, green: 108/255, blue: 182/255)

    // Cards & text
    static let cardBackground      = Color.white
    static let softCardBackground  = Color(red: 249/255, green: 249/255, blue: 255/255)
    static let subtitleText        = Color(red: 140/255, green: 143/255, blue: 160/255)
    static let headlineText        = Color(red: 32/255, green: 35/255, blue: 56/255)

    static let accentPurple = Color(red: 137/255, green: 74/255, blue: 255/255)
    static let accentPink   = Color(red: 233/255, green: 69/255, blue: 172/255)
    static let accentOrange = Color(red: 255/255, green: 168/255, blue: 0/255)
}

// MARK: - Roboto fonts

enum RobotoWeight: String {
    case regular = "Roboto-Regular"
    case medium  = "Roboto-Medium"
    case bold    = "Roboto-Bold"
}

extension Font {
    static func roboto(_ weight: RobotoWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}
