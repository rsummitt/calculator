//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Robert Summitt on 4/30/16.
//
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var opsString = ""
    
    private var pending: PendingBinaryOperation?
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var description: String {
        get {
            return opsString
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double){
        if(pending == nil){
            opsString = " "
        }
        opsString.appendContentsOf("\(operand)")
        accumulator = operand
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                performConstantOperation(symbol, value: value)
            case .UrnaryOperation(let function):
                performUrnaryOperation(symbol, function: function)
            case .BinaryOperation(let function):
                performBinaryOperation(symbol, function: function)
            case .Equals:
                performEqualsOperation(symbol)
            case .Clear:
                clear()
            }
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UrnaryOperation({-$0}),
        "%" : Operation.UrnaryOperation({$0/100.0}),
        "√" : Operation.UrnaryOperation(sqrt),
        "∛" : Operation.UrnaryOperation({pow($0, 1.0/3)}),
        "sin" : Operation.UrnaryOperation(sin),
        "cos" : Operation.UrnaryOperation(cos),
        "tan" : Operation.UrnaryOperation(tan),
        "ln" : Operation.UrnaryOperation(log),
        "x²" : Operation.UrnaryOperation({pow($0, 2)}),
        "x³" : Operation.UrnaryOperation({pow($0, 3)}),
        "xʸ" : Operation.BinaryOperation(pow),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "−" : Operation.BinaryOperation({$0 - $1}),
        "C" : Operation.Clear,
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UrnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Clear
        case Equals
    }
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func clear(){
        accumulator = 0.0
        opsString = " "
        pending = nil
    }
    
    private func performEqualsOperation(symbol: String){
        let lastChar = String(opsString.characters.suffix(1))
        if Int(lastChar) != nil {
            executePendingBinaryOperation()
        } else {
            opsString.appendContentsOf("\(accumulator)")
            executePendingBinaryOperation()
        }
    }
    
    private func performConstantOperation(symbol: String, value: Double){
        opsString.appendContentsOf(symbol)
        accumulator = value
    }
    
    private func performBinaryOperation(symbol: String, function: (Double, Double) -> Double){
        opsString.appendContentsOf(symbol)
        executePendingBinaryOperation()
        pending = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator)
    }
    
    private func performUrnaryOperation(symbol: String, function: (Double) -> Double){
        if(pending != nil){
            let accumulatorCharCount = "\(accumulator)".characters.count
            let startPoint = opsString.endIndex.advancedBy(-accumulatorCharCount)
            let endPoint = opsString.endIndex.advancedBy(0)
            let removeRange = startPoint ..< endPoint
            
            opsString.removeRange(removeRange)
            opsString.appendContentsOf("\(symbol) (\(accumulator))")
        } else {
            opsString = "\(symbol)(\(opsString))"
        }
        accumulator = function(accumulator)
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}