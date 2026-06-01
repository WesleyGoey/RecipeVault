//
//  MerriWeather.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//


import SwiftUI

// MARK: - Font Extension
extension Font {
    // MARK: - Merriweather Regular
    static func merriweather(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if #available(iOS 16.0, macOS 13.0, *) {
            return .system(size: size, weight: weight, design: .serif)
        } else {
            return .system(size: size, weight: weight)
        }
    }

    // MARK: - Merriweather Bold
    static func merriweather(_ size: CGFloat, weightBold: Bool) -> Font {
        return merriweather(size, weight: weightBold ? .bold : .regular)
    }
}
