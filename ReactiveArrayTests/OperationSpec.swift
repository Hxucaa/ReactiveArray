//
//  OperationSpec.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 7/2/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveArray
import ReactiveCocoa
import Box

class OperationSpec: QuickSpec {

    override func spec() {
        
        var operation: Operation<Int>!
        
        describe("#map") {
            
            context("when the operation is an Append operation") {
                
                beforeEach {
                    operation = Operation.Append(value: Box(10))
                }
                
                it("maps the value to be appended") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.Append(value: Box(20))
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is an Insert operation") {
                
                beforeEach {
                    operation = Operation.Insert(value: Box(10), atIndex: 5)
                }
                
                it("maps the value to be inserted") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.Insert(value: Box(20), atIndex: 5)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is a Delete operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("does nothing") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == operation
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the opearation is a ReplaceAll operation") {
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: Box([1,2,3,4]))
                }
                
                it("replaces the original data with a new array") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.ReplaceAll(values: Box([2,4,6,8]))
                    expect(areEqual).to(beTrue())
                }
            }
        }
        
        describe("#value") {
        
            context("when the operation is an Append operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Append(value: Box(data))
                }
                
                it("returns the appended value") {
                    expect(operation.value).to(equal(data))
                }
                
            }
            
            context("when the operation is an Insert operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Insert(value: Box(data), atIndex: 5)
                }
                
                it("returns the inserted value") {
                    expect(operation.value).to(equal(data))
                }
                
            }
            
            context("when the operation is an RemoveElement operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
            context("when the operation is an ReplaceAll operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: Box(array))
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
            context("when the operation is an RemoveAll operation") {
                
                beforeEach {
                    operation = Operation.RemoveAll(keepCapacity: true)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
        }
        
        describe("#arrayValue") {
            
            context("when the operation is an `Append` operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Append(value: Box(data))
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an `Insert` operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Insert(value: Box(data), atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an `RemoveElement` operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an ReplaceAll operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: Box(array))
                }
                
                it("returns the value that's going to replace all") {
                    expect(operation.arrayValue).to(equal(array))
                }
            }
            
            context("when the operation is an RemoveAll operation") {
                
                beforeEach {
                    operation = Operation.RemoveAll(keepCapacity: true)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
        }
        
    }
    
}