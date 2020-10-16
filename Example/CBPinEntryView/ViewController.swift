//
//  ViewController.swift
//  CBPinEntryView
//
//  Created by Chris Byatt on 03/18/2017.
//  Copyright (c) 2017 Chris Byatt. All rights reserved.
//

import UIKit
import CBPinEntryView

class ViewController: UIViewController {
    var isUnderlined = false

    @IBOutlet var pinEntryView: CBPinEntryView!
    @IBOutlet var stringOutputLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pinEntryView.delegate = self
        
        pinEntryView.becomeFirstResponder()
    }
    
    @IBAction func pressedGetCode(_ sender: UIButton) {
        stringOutputLabel.text = pinEntryView.getPinAsString()
        print(pinEntryView.getPinAsInt() ?? "Not an int")
        pinEntryView.resignFirstResponder()
    }

    @IBAction func toggleError(_ sender: UIButton) {
        if !pinEntryView.errorMode {
            pinEntryView.setError(isError: true)
        } else {
            pinEntryView.setError(isError: false)
        }
    }

    @IBAction func pressedClear(_ sender: UIButton) {
        pinEntryView.clearEntry()
    }
    @IBAction func pressedUnderline(_ sender: UIButton) {
        if pinEntryView.isUnderlined {
            pinEntryView.isUnderlined = false
        } else {
            pinEntryView.isUnderlined = true
        }
    }
}

extension ViewController: CBPinEntryViewDelegate {
    func entryCompleted(with entry: String?) {
        print(entry)
    }

    func entryChanged(_ completed: Bool) {
        if completed {
            print(pinEntryView.getPinAsString())
        }
    }
}

