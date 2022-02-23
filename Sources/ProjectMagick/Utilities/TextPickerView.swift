
import UIKit
import IQKeyboardManagerSwift

/** Assign to UITextfield to use it as a DatePicker or StringPicker  */

public enum TextPickerViewType {
    case date, strings
}

@objc public protocol TextPickerViewDelegate: AnyObject {
    // date picker delegate
    @objc optional func textPickerView(_ textPickerView: TextPickerView, didSelectDate date: Date)
    
    // strings picker delegate
    @objc optional func textPickerView(_ textPickerView: TextPickerView, didSelectString row: Int)
    func textPickerView(_ textPickerView: TextPickerView, titleForRow row: Int) -> String?
}

public protocol TextPickerDataSource: AnyObject {
    func numberOfRows(in pickerView: TextPickerView) -> Int
}

public class TextPickerView: UITextField {
    
    // MARK: public properties
    public var type: TextPickerViewType = .strings {
        didSet {
            updatePickerType()
        }
    }
    
    // date picker properties
    public var datePicker: UIDatePicker?
    
    
    // strings picker properties
    public var dataPicker: UIPickerView?
    public weak var pickerDataSource: TextPickerDataSource?
    
    // common properties
    public weak var pickerDelegate: TextPickerViewDelegate?
    
    
    
    // MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addDoneOnKeyboardWithTarget(self, action: #selector(doneClicked), titleText: SmallTitles.done)
        updatePickerType()
    }
    
    @objc func cancelClicked() {
        resignFirstResponder()
    }
    
    @objc func doneClicked() {
        switch type {
        case .date:
            if let picker = datePicker {
                dateChanged(picker)
            }
        default:
            if let index = dataPicker?.selectedRow(inComponent: 0) {
                pickerDelegate?.textPickerView?(self, didSelectString: index)
            }
        }
        resignFirstResponder()
    }
    
    override open func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    // MARK: private
    private func updatePickerType() {
        switch type {
        case .strings:
            initDataPicker()
        case .date:
            initDatePicker()
        }
    }
    
    // date picker setup
    private func initDatePicker() {
        dataPicker = nil
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
        datePicker?.datePickerMode = .date
        inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    
    @objc func dateChanged(_ sender : UIDatePicker) {
        pickerDelegate?.textPickerView?(self, didSelectDate: sender.date)
    }
    
    
    // strings data picker setup
    private func initDataPicker() {
        datePicker = nil
        dataPicker = UIPickerView()
        dataPicker?.backgroundColor = .white
        dataPicker?.delegate = self
        dataPicker?.dataSource = self
        inputView = dataPicker
    }
 
}

extension TextPickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource?.numberOfRows(in: self) ?? 0
    }
}

extension TextPickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let string = pickerDelegate?.textPickerView(self, titleForRow: row)
        return NSAttributedString(string: string!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDelegate?.textPickerView?(self, didSelectString: row)
    }
    
}
