//
//  File.swift
//  
//
//  Created by Kishan on 16/12/21.
//

import UIKit
import Darwin

// MARK: - Properties
public extension Int {
    
    /** ((self - (self % 15)) + 15) % 60 -- if you want to understand. */
    var nextHourQuarter: Int {
        return (self - self % 15 + 15) % 60
    }

    /// ProjectMagick: CountableRange 0..<Int.
    var countableRange: CountableRange<Int> {
        return 0..<self
    }

    /// ProjectMagick: Radian value of degree input.
    var degreesToRadians: Double {
        return Double.pi * Double(self) / 180.0
    }

    /// ProjectMagick: Degree value of radian input
    var radiansToDegrees: Double {
        return Double(self) * 180 / Double.pi
    }

    /// ProjectMagick: UInt.
    var uInt: UInt {
        return UInt(self)
    }

    /// ProjectMagick: Double.
    var double: Double {
        return Double(self)
    }

    /// ProjectMagick: Float.
    var float: Float {
        return Float(self)
    }

    #if canImport(CoreGraphics)
    /// ProjectMagick: CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    #endif

    /// ProjectMagick: String formatted for values over ±1000 (example: 1k, -2k, 100k, 1kk, -5kk..)
    var kFormatted: String {
        var sign: String {
            return self >= 0 ? "" : "-"
        }
        let abs = Swift.abs(self)
        if abs == 0 {
            return "0k"
        } else if abs >= 0 && abs < 1000 {
            return "0k"
        } else if abs >= 1000 && abs < 1000000 {
            return String(format: "\(sign)%ik", abs / 1000)
        }
        return String(format: "\(sign)%ikk", abs / 100000)
    }

}

// MARK: - Methods
public extension Int {

    /// ProjectMagick: check if given integer prime or not.
    /// Warning: Using big numbers can be computationally expensive!
    /// - Returns: true or false depending on prime-ness
    func isPrime() -> Bool {
        // To improve speed on latter loop :)
        if self == 2 { return true }

        guard self > 1 && self % 2 != 0 else { return false }

        // Explanation: It is enough to check numbers until
        // the square root of that number. If you go up from N by one,
        // other multiplier will go 1 down to get similar result
        // (integer-wise operation) such way increases speed of operation
        let base = Int(sqrt(Double(self)))
        for int in Swift.stride(from: 3, through: base, by: 2) where self % int == 0 {
            return false
        }
        return true
    }

    /// ProjectMagick: Roman numeral string from integer (if applicable).
    ///
    ///10.romanNumeral() -> "X"
    ///
    /// - Returns: The roman numeral string.
    func romanNumeral() -> String? {
        // https://gist.github.com/kumo/a8e1cb1f4b7cff1548c7
        guard self > 0 else { // there is no roman numeral for 0 or negative numbers
            return nil
        }
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]

        var romanValue = ""
        var startingValue = self

        for (index, romanChar) in romanValues.enumerated() {
            let arabicValue = arabicValues[index]
            let div = startingValue / arabicValue
            if div > 0 {
                for _ in 0..<div {
                    romanValue += romanChar
                }
                startingValue -= arabicValue * div
            }
        }
        return romanValue
    }

    /// ProjectMagick: Rounds to the closest multiple of n
    func roundToNearest(_ number: Int) -> Int {
        return number == 0 ? self : Int(round(Double(self) / Double(number))) * number
    }

}

// MARK: - Operators

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence
/// ProjectMagick: Value of exponentiation.
///
/// - Parameters:
///   - lhs: base integer.
///   - rhs: exponent integer.
/// - Returns: exponentiation result (example: 2 ** 3 = 8).
func ** (lhs: Int, rhs: Int) -> Double {
    // http://nshipster.com/swift-operators/
    return pow(Double(lhs), Double(rhs))
}

// swiftlint:disable identifier_name
prefix operator √
/// ProjectMagick: Square root of integer.
///
/// - Parameter int: integer value to find square root for
/// - Returns: square root of given integer.
public prefix func √ (int: Int) -> Double {
    // http://nshipster.com/swift-operators/
    return sqrt(Double(int))
}
// swiftlint:enable identifier_name

// swiftlint:disable identifier_name
infix operator ±
/// ProjectMagick: Tuple of plus-minus operation.
///
/// - Parameters:
///   - lhs: integer number.
///   - rhs: integer number.
/// - Returns: tuple of plus-minus operation (example: 2 ± 3 -> (5, -1)).
func ± (lhs: Int, rhs: Int) -> (Int, Int) {
    // http://nshipster.com/swift-operators/
    return (lhs + rhs, lhs - rhs)
}
// swiftlint:enable identifier_name

// swiftlint:disable identifier_name
prefix operator ±
/// ProjectMagick: Tuple of plus-minus operation.
///
/// - Parameter int: integer number
/// - Returns: tuple of plus-minus operation (example: ± 2 -> (2, -2)).
public prefix func ± (int: Int) -> (Int, Int) {
    // http://nshipster.com/swift-operators/
    return 0 ± int
}
// swiftlint:enable identifier_name


public extension BinaryFloatingPoint {

    #if canImport(Foundation)
    /// ProjectMagick: Returns a rounded value with the specified number of
    /// decimal places and rounding rule. If `numberOfDecimalPlaces` is negative,
    /// `0` will be used.
    ///
    ///     let num = 3.1415927
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .up) -> 3.142
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .down) -> 3.141
    ///     num.rounded(numberOfDecimalPlaces: 2, rule: .awayFromZero) -> 3.15
    ///     num.rounded(numberOfDecimalPlaces: 4, rule: .towardZero) -> 3.1415
    ///     num.rounded(numberOfDecimalPlaces: -1, rule: .toNearestOrEven) -> 3
    ///
    /// - Parameters:
    ///   - numberOfDecimalPlaces: The expected number of decimal places.
    ///   - rule: The rounding rule to use.
    /// - Returns: The rounded value.
    func rounded(numberOfDecimalPlaces: Int, rule: FloatingPointRoundingRule) -> Self {
        let factor = Self(pow(10.0, Double(max(0, numberOfDecimalPlaces))))
        return (self * factor).rounded(rule) / factor
    }
    #endif

}

// MARK: - Properties
public extension CGFloat {

    /// ProjectMagick: Absolute of CGFloat value.
    var abs: CGFloat {
        return Swift.abs(self)
    }

    /// ProjectMagick: Ceil of CGFloat value.
    var ceil: CGFloat {
        return Foundation.ceil(self)
    }

    /// ProjectMagick: Radian value of degree input.
    var degreesToRadians: CGFloat {
        return .pi * self / 180.0
    }

    /// ProjectMagick: Floor of CGFloat value.
    var floor: CGFloat {
        return Foundation.floor(self)
    }

    /// ProjectMagick: Check if CGFloat is positive.
    var isPositive: Bool {
        return self > 0
    }

    /// ProjectMagick: Check if CGFloat is negative.
    var isNegative: Bool {
        return self < 0
    }

    /// ProjectMagick: Int.
    var int: Int {
        return Int(self)
    }

    /// ProjectMagick: Float.
    var float: Float {
        return Float(self)
    }

    /// ProjectMagick: Double.
    var double: Double {
        return Double(self)
    }

    /// ProjectMagick: Degree value of radian input.
    var radiansToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }

}


// MARK: - Properties
public extension Double {

    /// ProjectMagick: Int.
    var int: Int {
        return Int(self)
    }

    /// ProjectMagick: Float.
    var float: Float {
        return Float(self)
    }

    #if canImport(CoreGraphics)
    /// ProjectMagick: CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    #endif

}

// MARK: - Operators
/// ProjectMagick: Value of exponentiation.
///
/// - Parameters:
///   - lhs: base double.
///   - rhs: exponent double.
/// - Returns: exponentiation result (example: 4.4 ** 0.5 = 2.0976176963).
func ** (lhs: Double, rhs: Double) -> Double {
    // http://nshipster.com/swift-operators/
    return pow(lhs, rhs)
}

/// ProjectMagick: Square root of double.
///
/// - Parameter double: double value to find square root for.
/// - Returns: square root of given double.
public prefix func √ (double: Double) -> Double {
    // http://nshipster.com/swift-operators/
    return sqrt(double)
}
// swiftlint:enable identifier_name


// MARK: - Properties
public extension Float {

    /// ProjectMagick: Int.
    var int: Int {
        return Int(self)
    }

    /// ProjectMagick: Double.
    var double: Double {
        return Double(self)
    }

    #if canImport(CoreGraphics)
    /// ProjectMagick: CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    #endif

}

// MARK: - Operators
/// ProjectMagick: Value of exponentiation.
///
/// - Parameters:
///   - lhs: base float.
///   - rhs: exponent float.
/// - Returns: exponentiation result (4.4 ** 0.5 = 2.0976176963).
func ** (lhs: Float, rhs: Float) -> Float {
    // http://nshipster.com/swift-operators/
    return pow(lhs, rhs)
}

/// ProjectMagick: Square root of float.
///
/// - Parameter float: float value to find square root for
/// - Returns: square root of given float.
public prefix func √ (float: Float) -> Float {
    // http://nshipster.com/swift-operators/
    return sqrt(float)
}
// swiftlint:enable identifier_name


// MARK: - Properties
public extension FloatingPoint {

    /// ProjectMagick: Absolute value of number.
    var abs: Self {
        return Swift.abs(self)
    }

    /// ProjectMagick: Check if number is positive.
    var isPositive: Bool {
        return self > 0
    }

    /// ProjectMagick: Check if number is negative.
    var isNegative: Bool {
        return self < 0
    }

    #if canImport(Foundation)
    /// ProjectMagick: Ceil of number.
    var ceil: Self {
        return Foundation.ceil(self)
    }
    #endif

    /// ProjectMagick: Radian value of degree input.
    var degreesToRadians: Self {
        return Self.pi * self / Self(180)
    }

    #if canImport(Foundation)
    /// ProjectMagick: Floor of number.
    var floor: Self {
        return Foundation.floor(self)
    }
    #endif

    /// ProjectMagick: Degree value of radian input.
    var radiansToDegrees: Self {
        return self * Self(180) / Self.pi
    }

}

// MARK: - Operators
/// ProjectMagick: Tuple of plus-minus operation.
///
/// - Parameters:
///   - lhs: number
///   - rhs: number
/// - Returns: tuple of plus-minus operation ( 2.5 ± 1.5 -> (4, 1)).
func ± <T: FloatingPoint> (lhs: T, rhs: T) -> (T, T) {
    // http://nshipster.com/swift-operators/
    return (lhs + rhs, lhs - rhs)
}
// swiftlint:enable identifier_name

// swiftlint:disable identifier_name

/// ProjectMagick: Tuple of plus-minus operation.
///
/// - Parameter int: number
/// - Returns: tuple of plus-minus operation (± 2.5 -> (2.5, -2.5)).
public prefix func ± <T: FloatingPoint> (number: T) -> (T, T) {
    // http://nshipster.com/swift-operators/
    return 0 ± number
}
// swiftlint:enable identifier_name


// MARK: - Properties
public extension SignedInteger {

    /// ProjectMagick: Absolute value of integer number.
    var abs: Self {
        return Swift.abs(self)
    }

    /// ProjectMagick: Check if integer is positive.
    var isPositive: Bool {
        return self > 0
    }

    /// ProjectMagick: Check if integer is negative.
    var isNegative: Bool {
        return self < 0
    }

    /// ProjectMagick: Check if integer is even.
    var isEven: Bool {
        return (self % 2) == 0
    }

    /// ProjectMagick: Check if integer is odd.
    var isOdd: Bool {
        return (self % 2) != 0
    }

    /// ProjectMagick: String of format (XXh XXm) from seconds Int.
    var timeString: String {
        guard self > 0 else {
            return "0 sec"
        }
        if self < 60 {
            return "\(self) sec"
        }
        if self < 3600 {
            return "\(self / 60) min"
        }
        let hours = self / 3600
        let mins = (self % 3600) / 60

        if hours != 0 && mins == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(mins)m"
    }

}

// MARK: - Methods
public extension SignedInteger {

    /// ProjectMagick: Greatest common divisor of integer value and n.
    ///
    /// - Parameter number: integer value to find gcd with.
    /// - Returns: greatest common divisor of self and n.
    func gcd(of number: Self) -> Self {
        return number == 0 ? self : number.gcd(of: self % number)
    }

    /// ProjectMagick: Least common multiple of integer and n.
    ///
    /// - Parameter number: integer value to find lcm with.
    /// - Returns: least common multiple of self and n.
    func lcm(of number: Self) -> Self {
        return (self * number).abs / gcd(of: number)
    }

    #if canImport(Foundation)
    /// ProjectMagick: Ordinal representation of an integer.
    ///
    ///        print((12).ordinalString()) // prints "12th"
    ///
    /// - Parameter locale: locale, default is .current.
    /// - Returns: string ordinal representation of number in specified locale language. E.g. input 92, output in "en": "92nd".
    @available(iOS 9.0, macOS 10.11, *)
    func ordinalString(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .ordinal
        guard let number = self as? NSNumber else { return nil }
        return formatter.string(from: number)
    }
    #endif

}


// MARK: - Properties
public extension SignedNumeric {

    /// ProjectMagick: String.
    var string: String {
        return String(describing: self)
    }

    #if canImport(Foundation)
    /// ProjectMagick: String with number and current locale currency.
    var asLocaleCurrency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        // swiftlint:disable:next force_cast
        return formatter.string(from: self as! NSNumber)
    }
    #endif

}

// MARK: - Methods
public extension SignedNumeric {

    #if canImport(Foundation)
    /// ProjectMagick: Spelled out representation of a number.
    ///
    ///        print((12.32).spelledOutString()) // prints "twelve point three two"
    ///
    /// - Parameter locale: Locale, default is .current.
    /// - Returns: String representation of number spelled in specified locale language. E.g. input 92, output in "en": "ninety-two"
    func spelledOutString(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .spellOut

        guard let number = self as? NSNumber else { return nil }
        return formatter.string(from: number)
    }
    #endif

}
