// LocaleExtensions.swift - Copyright 2020 ProjectMagick

#if canImport(Foundation)
import Foundation

// MARK: - Properties

public extension Locale {
    /// ProjectMagick: UNIX representation of locale usually used for normalizing.
    static var posix: Locale {
        return Locale(identifier: "en_US_POSIX")
    }

    /// ProjectMagick: Returns bool value indicating if locale has 12h format.
    var is12HourTimeFormat: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.locale = self
        let dateString = dateFormatter.string(from: Date())
        return dateString.contains(dateFormatter.amSymbol) || dateString.contains(dateFormatter.pmSymbol)
    }
}

// MARK: - Functions

public extension Locale {
    /// ProjectMagick: Get the flag emoji for a given country region code.
    /// - Parameter isoRegionCode: The IOS region code.
    ///
    /// Adapted from https://stackoverflow.com/a/30403199/1627511
    /// - Returns: A flag emoji string for the given region code (optional).
    static func flagEmoji(forRegionCode isoRegionCode: String) -> String? {
        #if !os(Linux)
        guard isoRegionCodes.contains(isoRegionCode) else { return nil }
        #endif

        return isoRegionCode.unicodeScalars.reduce(into: String()) {
            guard let flagScalar = UnicodeScalar(UInt32(127_397) + $1.value) else { return }
            $0.unicodeScalars.append(flagScalar)
        }
    }
}

#endif
