//
//  KeyboardHandler.swift
//  GyroMouse
//
//  Created by Matteo Riva on 29/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit

protocol KeyboardHandlerDelegate: class {
    func keyboardHandlerDidDeleteBackward(_ keyhandler: KeyboardHandler)
    func keyboardHandlerDidShowKeyboard(_ keyhandler: KeyboardHandler)
    func keyboardHandlerDidHideKeyboard(_ keyhandler: KeyboardHandler)
}

class KeyboardHandler: UITextField {
    
    weak var keyBoardDelegate: KeyboardHandlerDelegate?
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override var canResignFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.white
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        textColor = UIColor.white
        textAlignment = .center
        isHidden = true
        autocorrectionType = .no
        spellCheckingType = .no
        keyboardAppearance = .dark
        isUserInteractionEnabled = false
    }
    
    func showKeyboard() {
        text = ""
        isHidden = false
        becomeFirstResponder()
        keyBoardDelegate?.keyboardHandlerDidShowKeyboard(self)
    }
    
    func hideKeyboard() {
        isHidden = true
        resignFirstResponder()
        keyBoardDelegate?.keyboardHandlerDidHideKeyboard(self)
    }
    
    //MARK: - UIKetInput
    
    override func deleteBackward() {
        super.deleteBackward()
        keyBoardDelegate?.keyboardHandlerDidDeleteBackward(self)
    }

}
