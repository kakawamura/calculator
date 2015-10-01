//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by kawamura.kazushi on 2015/10/01.
//  Copyright (c) 2015年 donuts. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // Printable is a protocol
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    // array
    private var opStack = [Op]()
    
    // dictionary
    private var knownOps = [String:Op]()
    
    // initializer
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $1 })
        learnOp(Op.UnaryOperation("√", sqrt))
    }
    
    // array and dictionary are structs 
    // 1. struct are passed by value, classes are passed by refrence
    // implicit let on params
    private func evaluate(ops: [Op]) -> (result: Double?, remaingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainigOps = ops
            let op = remainigOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainigOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainigOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainigOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remaingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remaingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    // Can't evalute if there is not enough operand so it returns an optional
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
}
