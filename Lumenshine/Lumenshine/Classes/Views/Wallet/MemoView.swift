//
//  MemoView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MemoView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var memoInputErrorLabel: UILabel!
    @IBOutlet weak var memoTypeTextField: UITextField!
    @IBOutlet weak var memoInputTextField: UITextField!
    
    @IBOutlet weak var memoInputErrorView: UIView!
    
    private var memoTypePickerView: UIPickerView!
    private let memoTypes: [MemoTypeValues] = [MemoTypeValues.MEMO_TEXT, MemoTypeValues.MEMO_ID, MemoTypeValues.MEMO_HASH, MemoTypeValues.MEMO_RETURN]
    
    var contentView: UIScrollView?
    var hasMemo: Bool {
        return memoInputTextField.text?.isMandatoryValid() ?? false
    }
    
    var memo: String? {
        get {
            return memoInputTextField.text
        }
        set {
            memoInputTextField.text = newValue
        }
    }
    
    var memoType: String? {
        get {
            return memoTypeTextField.text
        }
        set {
            memoTypeTextField.text = newValue
        }
    }
    
    var getMemoType: MemoTypeValues {
        return memoTypes.first(where: { (memoType) -> Bool in
            if let selectedMemoType = self.memoType {
                return memoType.rawValue == selectedMemoType
            }
        
            return memoType.rawValue == MemoTypeValues.MEMO_TEXT.rawValue
        }) ?? MemoTypeValues.MEMO_TEXT
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMemoTypePicker()
    }
    
    func resetValidationErrors() {
        memoInputErrorView.isHidden = true
        memoInputErrorLabel.text = nil
    }
    
    func resetToDefault() {
        memo = nil
        memoType = MemoTypeValues.MEMO_TEXT.rawValue
    }
    
    func validateMemo() -> Bool{
        if let memoText = self.memoInputTextField.text {
            if memoText.isEmpty == true {
                return true
            }
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                let memoTextValidationResult: MemoTextValidationResult = memoText.isMemoTextValid(limitNrOfBytes: MaximumLengthInBytesForMemoText)
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidEncoding {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                    return false
                }
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidLength {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .MemoLength)
                    return false
                }
                
            case MemoTypeValues.MEMO_ID.rawValue:
                if !memoText.isMemoIDValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                    return false
                }
                
            case MemoTypeValues.MEMO_HASH.rawValue:
                if !memoText.isMemoHashValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                    return false
                }
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                if !memoText.isMemoReturnValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                    return false
                }
                
            default:
                return true
            }
        }
        return true
    }
    
    private var selectedMemoType: MemoTypeValues! = MemoTypeValues.MEMO_TEXT {
        didSet {
            memoTypeTextField.text = selectedMemoType.rawValue
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoText.rawValue
                memoInputTextField.keyboardType = .default
                
            case MemoTypeValues.MEMO_ID.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoID.rawValue
                memoInputTextField.keyboardType = .numberPad
                
            case MemoTypeValues.MEMO_HASH.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                memoInputTextField.keyboardType = .default
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                memoInputTextField.keyboardType = .default
                
            default:
                break
            }
        }
    }
    
    private func setupMemoTypePicker() {
        memoTypePickerView = UIPickerView()
        memoTypePickerView.delegate = self
        memoTypePickerView.dataSource = self
        memoTypeTextField.text = selectedMemoType.rawValue
        memoTypeTextField.inputView = memoTypePickerView
        memoTypeTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(memoTypeDoneButtonTap))
    }
    
    private func setValidationError(view: UIView, label: UILabel, errorMessage: ValidationErrors) {
        view.isHidden = false
        label.text = errorMessage.rawValue
        
        contentView?.setContentOffset(CGPoint(x: 0, y: view.frame.center.y), animated: false)
    }
    
    private func selectAsset(row: Int) {
        selectedMemoType = memoTypes[row]
    }

    @objc func memoTypeDoneButtonTap(_ sender: Any) {
        selectAsset(row: memoTypePickerView.selectedRow(inComponent: 0))
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == memoTypePickerView {
            return memoTypes.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == memoTypePickerView {
            return memoTypes[row].rawValue
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(row: row)
    }
}
