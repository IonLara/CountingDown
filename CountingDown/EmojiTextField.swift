//
//  EmojiTextField.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 19/06/23.
//

import Foundation
import UIKit

class EmojiTextField: UITextField {
    
    override var textInputContextIdentifier: String? { "" }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}
