//
//  UITextfield.swift
//  ProjectMagick
//
//  Created by Kishan on 31/07/21.
//  Copyright © 2021 Kishan. All rights reserved.
//

import UIKit


public protocol TextFieldValidator : AnyObject {
    var validationFamily : TextFieldValidatorType { get set }
    var validationMessage : String { get set }
    var isValid : Bool { get }
    var minimumPasswordLength : Int { get set }
    var minimumPhoneNumberLength : ClosedRange<Int> { get set }
}


public struct NameFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyFirstName = NameFamilyValidationTypes(rawValue: 1)
    public static let validFirstName = NameFamilyValidationTypes(rawValue: 2)
    public static let emptyMiddleName = NameFamilyValidationTypes(rawValue: 4)
    public static let validMiddleName = NameFamilyValidationTypes(rawValue: 8)
    public static let emptyLastName = NameFamilyValidationTypes(rawValue: 16)
    public static let validLastName = NameFamilyValidationTypes(rawValue: 32)
    
}

public struct EmailFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyEmail = EmailFamilyValidationTypes(rawValue: 1)
    public static let validEmail = EmailFamilyValidationTypes(rawValue: 2)
}

public struct BirthDateFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyBirthDate = BirthDateFamilyValidationTypes(rawValue: 1)
}

public struct GenderFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyGender = GenderFamilyValidationTypes(rawValue: 1)
}

public struct JustAddressFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyAddress = JustAddressFamilyValidationTypes(rawValue: 1)
}

public struct PhoneNumberFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyPhoneNumber = PhoneNumberFamilyValidationTypes(rawValue: 1)
    public static let validPhoneNumber = PhoneNumberFamilyValidationTypes(rawValue: 2)
}

public struct PasswordFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyPassword = PasswordFamilyValidationTypes(rawValue: 1)
    public static let emptyConfirmPassword = PasswordFamilyValidationTypes(rawValue: 2)
    public static let minimumCharacters = PasswordFamilyValidationTypes(rawValue: 4)
    public static let alphaNumeric = PasswordFamilyValidationTypes(rawValue: 8)
    public static let oneCapitalLetterOneNumberOneSpecialCharacter = PasswordFamilyValidationTypes(rawValue: 16)
}

public struct CreditCardFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyName = CreditCardFamilyValidationTypes(rawValue: 1)
    public static let emptyCreditCardNumber = CreditCardFamilyValidationTypes(rawValue: 2)
    public static let validCreditCardNumber = CreditCardFamilyValidationTypes(rawValue: 4)
    public static let emptyCVVNumber = CreditCardFamilyValidationTypes(rawValue: 8)
    public static let validCVVNumber = CreditCardFamilyValidationTypes(rawValue: 16)
}

public struct GoogleAddressFamilyValidationTypes : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let emptyAddress1 = GoogleAddressFamilyValidationTypes(rawValue: 1)
    public static let emptyAddress2 = GoogleAddressFamilyValidationTypes(rawValue: 2)
    public static let emptyCity = GoogleAddressFamilyValidationTypes(rawValue: 4)
    public static let emptyState = GoogleAddressFamilyValidationTypes(rawValue: 8)
    public static let emptyCountry = GoogleAddressFamilyValidationTypes(rawValue: 16)
    public static let emptyPostalCode = GoogleAddressFamilyValidationTypes(rawValue: 32)
}

public enum TextFieldValidatorType {
    case familyOfNames(applyFor: NameFamilyValidationTypes)
    case familyOfEmail(applyFor: EmailFamilyValidationTypes)
    case familyOfBirthDate(applyFor: BirthDateFamilyValidationTypes)
    case familyOfPhone(applyFor: PhoneNumberFamilyValidationTypes)
    case familyOfCreditCard(applyFor: CreditCardFamilyValidationTypes)
    case familyOfGoogleAddress(applyFor: GoogleAddressFamilyValidationTypes)
    case familyOfJustAddress(applyFor: JustAddressFamilyValidationTypes)
    case familyOfPassword(applyFor: PasswordFamilyValidationTypes)
    case familyOfGender(applyFor: GenderFamilyValidationTypes)
    case none
}

public enum ResponderStandardEditActions {
    case cut, copy, paste, select, selectAll, delete
    case makeTextWritingDirectionLeftToRight, makeTextWritingDirectionRightToLeft
    case toggleBoldface, toggleItalics, toggleUnderline
    case increaseSize, decreaseSize
    
    var selector: Selector {
        switch self {
        case .cut:
            return #selector(UIResponderStandardEditActions.cut)
        case .copy:
            return #selector(UIResponderStandardEditActions.copy)
        case .paste:
            return #selector(UIResponderStandardEditActions.paste)
        case .select:
            return #selector(UIResponderStandardEditActions.select)
        case .selectAll:
            return #selector(UIResponderStandardEditActions.selectAll)
        case .delete:
            return #selector(UIResponderStandardEditActions.delete)
        case .toggleBoldface:
            return #selector(UIResponderStandardEditActions.toggleBoldface)
        case .toggleItalics:
            return #selector(UIResponderStandardEditActions.toggleItalics)
        case .toggleUnderline:
            return #selector(UIResponderStandardEditActions.toggleUnderline)
        case .increaseSize:
            return #selector(UIResponderStandardEditActions.increaseSize)
        case .decreaseSize:
            return #selector(UIResponderStandardEditActions.decreaseSize)
        case .makeTextWritingDirectionLeftToRight:
            return #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight)
        case .makeTextWritingDirectionRightToLeft:
            return #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft)
        }
    }
}

open class ThemeTextField: SkyFloatingLabelTextField, TextFieldValidator {
    
    //MARK:- Variables
    public var validationMessage: String = ""
    public var minimumPasswordLength: Int = 6
    public var minimumPhoneNumberLength: ClosedRange<Int> = 8...11
    public var validationFamily: TextFieldValidatorType = .none {
        didSet {
            applyTextfieldStyle(type: validationFamily)
        }
    }
    private var editActions: [ResponderStandardEditActions: Bool]?
    private var filterEditActions: [ResponderStandardEditActions: Bool]?
    
    private func filterEditActions(actions: [ResponderStandardEditActions], allowed: Bool) {
        if self.filterEditActions == nil { self.filterEditActions = [:] }
        editActions = nil
        actions.forEach { self.filterEditActions?[$0] = allowed }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}

public extension ThemeTextField {
    
    func setEditActions(only actions: [ResponderStandardEditActions]) {
        if self.editActions == nil { self.editActions = [:] }
        filterEditActions = nil
        actions.forEach { self.editActions?[$0] = true }
    }
    
    func addToCurrentEditActions(actions: [ResponderStandardEditActions]) {
        if self.filterEditActions == nil { self.filterEditActions = [:] }
        editActions = nil
        actions.forEach { self.filterEditActions?[$0] = true }
    }
    
    
    func filterEditActions(notAllowed: [ResponderStandardEditActions]) {
        filterEditActions(actions: notAllowed, allowed: false)
    }
    
    func resetEditActions() {
        editActions = nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let actions = editActions {
            for _action in actions where _action.key.selector == action { return _action.value }
            return false
        }
        
        if let actions = filterEditActions {
            for _action in actions where _action.key.selector == action { return _action.value }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    fileprivate func applyTextfieldStyle(type : TextFieldValidatorType) {
        switch type {
        case .familyOfEmail:
            keyboardType = .emailAddress
        case .familyOfPhone:
            keyboardType = .phonePad
        case .familyOfPassword:
            isSecureTextEntry = true
        case let .familyOfCreditCard(values):
            if values.contains(.emptyName) {
                keyboardType = .default
            } else {
                keyboardType = .numberPad
            }
        default:
            keyboardType = .default
        }
    }
    
    var isValid : Bool {
        
        switch validationFamily {
            
        case let .familyOfNames(values):
            
            if values.contains(.emptyFirstName) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterFirstName
                    return false
                }
            }
            if values.contains(.emptyMiddleName) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterMiddleName
                    return false
                }
            }
            if values.contains(.emptyLastName) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterLastName
                    return false
                }
            }
            
        case let .familyOfEmail(values):
            
            if values.contains(.emptyEmail) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterEmailAddress
                    return false
                }
            }
            
            if values.contains(.validEmail) {
                if text!.isValidEmail {
                    validationMessage = TextFieldValidationMessages.enterValidEmail
                    return false
                }
            }
            
        case let .familyOfPhone(values):
            
            if values.contains(.emptyPhoneNumber) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterPhoneNumber
                    return false
                }
            }
            
            if values.contains(.validPhoneNumber) {
                if !minimumPhoneNumberLength.contains(text!.count) {
                    validationMessage = TextFieldValidationMessages.enterValidPhoneNumber
                    return false
                }
            }
            
        case let .familyOfBirthDate(values):
            
            if values.contains(.emptyBirthDate) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterBirthDate
                    return false
                }
            }
            
        case let .familyOfCreditCard(values):
            
            if values.contains(.emptyName) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterCardName
                    return false
                }
            }
            if values.contains(.emptyCreditCardNumber) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterCardNumber
                    return false
                }
            }
            if values.contains(.validCreditCardNumber) {
                if text!.count < 15 {
                    validationMessage = TextFieldValidationMessages.enterValidCardNumber
                    return false
                }
            }
            if values.contains(.emptyCVVNumber) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterCVVNumber
                    return false
                }
            }
            if values.contains(.validCVVNumber) {
                if text!.count < 2 {
                    validationMessage = TextFieldValidationMessages.enterValidCVVNumber
                    return false
                }
            }
            
        case let .familyOfGoogleAddress(values):
            
            if values.contains(.emptyAddress1) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterAddressLine1
                    return false
                }
            }
            if values.contains(.emptyAddress2) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterAddressLine2
                    return false
                }
            }
            if values.contains(.emptyCity) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterCityName
                    return false
                }
            }
            if values.contains(.emptyState) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterStateName
                    return false
                }
            }
            if values.contains(.emptyCountry) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterCountryName
                    return false
                }
            }
            if values.contains(.emptyPostalCode) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterPostalCode
                    return false
                }
            }
            
        case let .familyOfJustAddress(values):
            
            if values.contains(.emptyAddress) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterJustAddress
                    return false
                }
            }
            
        case let .familyOfPassword(values):
            
            if values.contains(.emptyPassword) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterPassword
                    return false
                }
            }
            if values.contains(.emptyConfirmPassword) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.enterConfirmPassword
                    return false
                }
            }
            if values.contains(.minimumCharacters) {
                if minimumPasswordLength < text!.count {
                    validationMessage = TextFieldValidationMessages.minimumCharacters
                    return false
                }
            }
            if values.contains(.alphaNumeric) {
                if !text!.isAlphaNumeric {
                    validationMessage = TextFieldValidationMessages.alphaNumericPassword
                    return false
                }
            }
            if values.contains(.oneCapitalLetterOneNumberOneSpecialCharacter) {
                if !text!.matches(pattern: RegexPatterns.oneCapLetterNumberSpecialCharacter) {
                    validationMessage = TextFieldValidationMessages.oneCapsLetterNumberAndSpecialCharacter
                    return false
                }
            }
            
        case let .familyOfGender(values):
            
            if values.contains(.emptyGender) {
                if text!.isEmpty {
                    validationMessage = TextFieldValidationMessages.selectGender
                    return false
                }
            }
            
        case .none:
            validationMessage = TextFieldValidationMessages.noValidationFound
            return false
        }
        return true
    }
}



public extension SkyFloatingLabelTextField {
    
    /*
    func applyBlackThemeStyle() {
        lineColor = UIColor.borderBlue
        backgroundColor = .clear
        textColor = .primary
        lineHeight = 1
//        font(name: .GalanoGrotesqueLight, size: 14)
        rightViewMode = .always
        titleLabel.isHidden = true
        lineVerticalSpacing = 8
        tintColor = .primary
        disabledColor = .textSecondary
        selectedLineColor = .primary
        autocapitalizationType = .words
        titleColor = .primary
        selectedTitleColor = .primary
//        titleFont = UIFont.customFont(ofType: .GalanoGrotesqueMedium, withSize: 12)
        /*
         errorLabel.isHidden = false
         errorMessagePlacement = .bottom
         titleFormatter = { text in
         text
         }
         borderColor(color: .clear)
         titleLabel.font(name: .OpenSansRegular, size: 8)
         */
    }
     */
    
}

public struct TextFieldValidationMessages {
    
}

public extension TextFieldValidationMessages {
    static let enterFirstName = "Please enter your first name."
    static let enterMiddleName = "Please enter your middle name."
    static let enterLastName = "Please enter your last name."
    static let enterEmailAddress = "Please enter email address."
    static let enterValidEmail = "Please enter a valid email address."
    static let enterPhoneNumber = "Please enter a phone number."
    static let enterValidPhoneNumber = "Please enter a valid phone number."
    static let enterBirthDate = "Please enter your birthdate."
    static let enterCardName = "Please enter your full name as per card."
    static let enterCardNumber = "Please enter your card number."
    static let enterValidCardNumber = "Please enter a valid credit card number."
    static let enterCVVNumber = "Please enter a CVV number."
    static let enterValidCVVNumber = "Please enter a valid CVV number."
    static let enterAddressLine1 = "Please fill address1."
    static let enterAddressLine2 = "Please fill address2."
    static let enterCityName = "Please enter city name."
    static let enterStateName = "Please enter state name."
    static let enterCountryName = "Please enter country name."
    static let enterPostalCode = "Please enter postal code."
    static let enterJustAddress = "Please enter your address."
    static let enterPassword = "Please enter your password."
    static let minimumCharacters = "Password must be minimum 6 characters long."
    static let oneCapsLetterNumberAndSpecialCharacter = "Password must contain one capital letter, special character and number."
    static let alphaNumericPassword = "Password must contains one letter and number."
    static let enterConfirmPassword = "Please enter your confirm password."
    static let selectGender = "Please provide us your gender type."
    static let noValidationFound = "No validations found! Please apply one."
}
