////
////  KeyboardViewController.swift
////  Helper Keyboard
////
////  Created by Victor Zhong on 11/1/19.
////  Copyright © 2019 Victor Zhong. All rights reserved.
////
//
//import UIKit
//
//class KeyboardViewController: UIInputViewController {
//
//    @IBOutlet var nextKeyboardButton: UIButton!
//
//    override func updateViewConstraints() {
//        super.updateViewConstraints()
//
//        // Add custom view sizing constraints here
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Perform custom UI setup here
//        self.nextKeyboardButton = UIButton(type: .system)
//
//        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
//        self.nextKeyboardButton.sizeToFit()
//        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
//
//        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
//
//        self.view.addSubview(self.nextKeyboardButton)
//
//        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//    }
//
//    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
//        super.viewWillLayoutSubviews()
//    }
//
//    override func textWillChange(_ textInput: UITextInput?) {
//        // The app is about to change the document's contents. Perform any preparation here.
//    }
//
//    override func textDidChange(_ textInput: UITextInput?) {
//        // The app has just changed the document's contents, the document context has been updated.
//
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.white
//        } else {
//            textColor = UIColor.black
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, for: [])
//    }
//
//}

import UIKit

class KeyboardViewController: UIInputViewController {

    var capsLockOn = true

    var currentWord = ""

let placeholderText = "Start Typing!"

    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    @IBOutlet weak var row4: UIView!

    @IBOutlet weak var charSet1: UIView!
    @IBOutlet weak var charSet2: UIView!

    @IBOutlet weak var suggestionButton: UIButton!

    @IBAction func suggestionButtonTapped(_ sender: Any) {
        guard suggestionButton.titleLabel?.text != placeholderText else { return }

        for _ in 0..<currentWord.count {
            textDocumentProxy.deleteBackward()
        }

        let suggestionUsed = suggestionButton.titleLabel?.text ?? ""
        textDocumentProxy.insertText(suggestionUsed)
        currentWord = suggestionUsed
        suggestionButton.setTitle(placeholderText, for: .normal)
    }

    var suggestionString: UILexicon?

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "KeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as? UIView

        charSet2.isHidden = true
    }

    @IBAction func nextKeyboardPressed(button: UIButton) {
        advanceToNextInputMode()
    }

    @IBAction func capsLockPressed(button: UIButton) {
        capsLockOn = !capsLockOn

        changeCaps(containerView: row1)
        changeCaps(containerView: row2)
        changeCaps(containerView: row3)
        changeCaps(containerView: row4)
    }

    @IBAction func keyPressed(button: UIButton) {
        let string = button.titleLabel!.text
        (textDocumentProxy as UIKeyInput).insertText("\(string!)")
        currentWord += string!

        // TODO: Guess sentence
        suggestionButton.setTitle("Add Bullsheet", for: .normal)


        UIView.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }, completion: {(_) -> Void in
            button.transform =
                CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    @IBAction func backSpacePressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).deleteBackward()
        _ = currentWord.popLast()
    }

    @IBAction func spacePressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).insertText(" ")
        currentWord += " "
    }

    @IBAction func returnPressed(button: UIButton) {
//        (textDocumentProxy as UIKeyInput).insertText("\n")
    }

    @IBAction func charSetPressed(button: UIButton) {
        if button.titleLabel!.text == "1/2" {
            charSet1.isHidden = true
            charSet2.isHidden = false
            button.setTitle("2/2", for: .normal)
        } else if button.titleLabel!.text == "2/2" {
            charSet1.isHidden = false
            charSet2.isHidden = true
            button.setTitle("1/2", for: .normal)
        }
    }

    func changeCaps(containerView: UIView) {
        for view in containerView.subviews {
            if let button = view as? UIButton {
                let buttonTitle = button.titleLabel!.text
                if capsLockOn {
                    let text = buttonTitle!.uppercased()
                    button.setTitle("\(text)", for: .normal)
                } else {
                    let text = buttonTitle!.lowercased()
                    button.setTitle("\(text)", for: .normal)
                }
            }
        }
    }


}
