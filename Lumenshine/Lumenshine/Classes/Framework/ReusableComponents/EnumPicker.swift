//
//  EnumPicker.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class EnumPicker: UIPickerView {
    
    // MARK: Properties
    
    /// The values that can be selected in the picker view.
    var enumValues = [String]()
    
    /// The index of the currently-selected value.
    var currentValue: Int? {
        didSet {
            if currentValue != nil {
                selectRow(currentValue!, inComponent: 0, animated: false)
            }
        }
    }
    
    /// A block to execute when the selected value changes.
    var selectionChangeHandler: (Int) -> Void = { newRow in return }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        delegate = self
        dataSource = self
    }
    
    // MARK: Interface
    
    /// Set the enum values to display, the index of the currently-selected value, and a block to execute when the selected value changes.
    func setValues(_ values: [String], currentSelection: Int?, selectionChanged: @escaping (Int) -> Void) {
        enumValues = values
        currentValue = currentSelection
        selectionChangeHandler = selectionChanged
    }
}

extension EnumPicker: UIPickerViewDataSource {
    /// Return the number of components in the picker, always returns 1.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Returns the number of enum values.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enumValues.count
    }
}

extension EnumPicker: UIPickerViewDelegate {
    /// Returns the enum value at the given row.
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: enumValues[row])
    }
    
    /// Handle the user selecting a value in the picker.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionChangeHandler(row)
    }
}
