import SwiftUI

extension Font {
    /// Returns Merriweather at a given point size. Falls back to system font if unavailable.
    static func merriweather(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if #available(iOS 16.0, macOS 13.0, *) {
            return .system(size: size, weight: weight, design: .serif)
        } else {
            return .system(size: size, weight: weight)
        }
    }

    /// Convenience that maps a boolean bold flag to weight.
    static func merriweather(_ size: CGFloat, weightBold: Bool) -> Font {
        return merriweather(size, weight: weightBold ? .bold : .regular)
    }
}
