//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by kawamura.kazushi on 2015/10/01.
//  Copyright (c) 2015年 donuts. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    // array
    private var opStack = [Op]()
    
    // dictionary
    private var knownOps = [String:Op]()
    
    // initializer
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $1 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
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
    
    // Can't evalute if there is not enough operand
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
}
