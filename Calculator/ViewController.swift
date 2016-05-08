//
//  ViewController.swift
//  Calculator
//
//  Created by Robert Summitt on 4/29/16.
//
//

import UIKit

class ViewController: UIViewController {
    
    private var brain = CalculatorBrain()
    
    private var userIsInTheMiddleOfTyping = false
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBAction private func touchDigit(sender: UIButton) {
        
        if let digit = sender.currentTitle {
            if(userIsInTheMiddleOfTyping){
                if let textCurrentlyInDisplay = display.text {
                    if(textCurrentlyInDisplay.rangeOfString(".") == nil || digit != "."){
                        display.text = textCurrentlyInDisplay + digit
                    }
                }
            } else {
                display.text = digit
            }
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        
        if(userIsInTheMiddleOfTyping){
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        descLabel.text = brain.description
        if(brain.isPartialResult){
            descLabel.text?.appendContentsOf("...")
        } else {
            descLabel.text?.appendContentsOf("=")
        }
        
        displayValue = brain.result
    }
}