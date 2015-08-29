//
//  ReactiveArraySpec.swift
//  ReactiveArraySpec
//
//  Created by Guido Marucci Blas on 6/29/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveArray
import ReactiveCocoa
import Box

private func waitForOperation<T>(
    fromProducer producer: SignalProducer<Operation<T>, NoError>,
    #when: () -> (),
    onAppend: Box<T> -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onExtend: Box<[T]> -> () = {
        fail("Invalid operation type: .Extend(\($0))")
    },
    onReplace: (Box<T>, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1.value))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: Box<[T]> -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        waitUntil { done in
            producer |> start(next: { operation in
                switch operation {
                case let .Append(boxedValue):
                    onAppend(boxedValue)
                case let .Extend(boxedValues):
                    onExtend(boxedValues)
                case let .Replace(boxedValue, index):
                    onReplace(boxedValue, index)
                case let .RemoveElement(index):
                    onDelete(index)
                case let .ReplaceAll(boxedValues):
                    onReplaceAll(boxedValues)
                case let .RemoveAll(keepCapacity):
                    onRemoveAll(keepCapacity)
                }
                done()
            })
            when()
        }
        
}

private func waitForOperation<T>(
    fromSignal signal: Signal<Operation<T>, NoError>,
    #when: () -> (),
    onAppend: Box<T> -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onExtend: Box<[T]> -> () = {
        fail("Invalid operation type: .Extend(\($0))")
    },
    onReplace: (Box<T>, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1.value))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: Box<[T]> -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        let producer = SignalProducer<Operation<T>, NoError> { (observer, disposable) in signal.observe(observer) }
        waitForOperation(fromProducer: producer, when: when, onAppend: onAppend, onExtend: onExtend, onReplace: onReplace, onDelete: onDelete, onReplaceAll: onReplaceAll, onRemoveAll: onRemoveAll)
}

private func waitForOperation<T>(
    fromArray array: ReactiveArray<T>,
    #when: () -> (),
    onAppend: Box<T> -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onExtend: Box<[T]> -> () = {
        fail("Invalid operation type: .Extend(\($0))")
    },
    onReplace: (Box<T>, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1.value))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: Box<[T]> -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        waitForOperation(fromSignal: array.signal, when: when, onAppend: onAppend, onExtend: onExtend, onReplace: onReplace, onDelete: onDelete, onReplaceAll: onReplaceAll, onRemoveAll: onRemoveAll)
}

class ReactiveArraySpec: QuickSpec {
    
    override func spec() {
        
        var originalData: [Int]!
        var reactiveArray: ReactiveArray<Int>!
        
        beforeEach {
            originalData = [1,2,3,4]
            reactiveArray = ReactiveArray(elements: originalData)
        }
        
        describe("#append") {
            
            it("appends the given element at the end of the array") {
                reactiveArray.append(5)
                
                expect(reactiveArray[reactiveArray.count - 1]).to(equal(5))
            }
            
            it("increments the amount of elements in the array by one") {
                let countBeforeAppend = reactiveArray.count
                
                reactiveArray.append(5)
                
                expect(reactiveArray.count).to(equal(countBeforeAppend + 1))
            }
            
            it("signals an append operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.append(5)
                    },
                    onAppend: { boxedValue in
                        expect(boxedValue.value).to(equal(5))
                    }
                )
            }
            
        }
        
        describe("#extend") {
            
            var originalCount: Int!
            let additionalArray = [5,6,7,8]
            
            beforeEach {
                originalCount = reactiveArray.count
            }
            
            it("should extend the array with an additional array of elements") {
                reactiveArray.extend(additionalArray)
                
                var newArray = reactiveArray.array
                newArray.removeRange(0...(originalCount - 1))
                
                expect(newArray).to(equal(additionalArray))
            }
            
            it("should increment the number of elements in the array by the number of new elements") {
                reactiveArray.extend(additionalArray)
                
                expect(reactiveArray.count).to(equal(originalCount + additionalArray.count))
            }
            
            it("should signal an `Extend` operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.extend(additionalArray)
                    },
                    onExtend: { boxedValues in
                        originalData.extend(additionalArray)
                        
                        expect(boxedValues.value).to(equal(additionalArray))
                    }
                )
            }
        }
        
        describe("#replace") {
            
            context("when there is a value at the given position") {
                
                it("replaces the old value with the new one") {
                    reactiveArray.replace(5, atIndex: 1)
                    
                    expect(reactiveArray[1]).to(equal(5))
                }
                
                it("signals an `.Replace` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.replace(5, atIndex: 1)
                        },
                        onReplace: { (boxedValue, index) in
                            expect(boxedValue.value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
                it("should return the original element at the given index") {
                    let index = 2
                    let originalElement = reactiveArray.array[index]
                    let replacedElement = reactiveArray.replace(9, atIndex: index)
                    
                    expect(replacedElement).to(equal(originalElement))
                }
                
            }
            
            // TODO: Fix this case because this raises an exception that cannot
            // be caught
//            context("when the index is out of bounds") {
//
//                it("raises an exception") {
//                    expect {
//                        array.replace(5, atIndex: array.count + 10)
//                    }.to(raiseException(named: "NSInternalInconsistencyException"))
//                }
//
//            }
            
        }
        
        describe("#removeAtIndex") {
            
            it("removes the element at the given position") {
                reactiveArray.removeAtIndex(1)
                
                expect(reactiveArray.array).to(equal([1,3,4]))
            }
            
            it("signals a delete operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.removeAtIndex(1)
                    },
                    onDelete: { index in
                        expect(index).to(equal(1))
                    }
                )
            }
            
            it("should return the element that is being removed") {
                let index = 1
                let originalElement = reactiveArray.array[index]
                let removedElement = reactiveArray.removeAtIndex(index)
                
                expect(removedElement).to(equal(originalElement))
            }
        }
        
        describe("#replaceAll") {
            
            let data = [1,3,5,7,9]
            
            it("should replace the element with a new array of data") {
                reactiveArray.replaceAll(data)
                
                expect(reactiveArray.array).to(equal(data))
            }
            
            it("should signal a `ReplaceAll` opearation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.replaceAll(data)
                    },
                    onReplaceAll: { boxedValues in
                        expect(boxedValues.value).to(equal(data))
                        expect(boxedValues.value).toNot(equal(originalData))
                    }
                )
            }
        }
        
        describe("#removeAll") {
            
            let removeOp = { (keepCapacity: Bool) in
                waitUntil { done in
                    let countBeforeOperation = reactiveArray.count
                    
                    reactiveArray.observableCount.producer
                        |> take(2)
                        |> collect
                        |> start(next: { counts in
                            expect(counts).to(equal([countBeforeOperation, 0]))
                            done()
                        })
                    
                    reactiveArray.removeAll(keepCapacity)
                }
            }
            
            context("when `keepCapacity` is set to `true`") {
                
                it("should remove all elements in the array") {
                    removeOp(true)
                }
                
                it("should signal a `RemoveAll` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.removeAll(true)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(true))
                        }
                    )
                }
            }
            
            context("when `keepCapacity` is set to `false`") {
                it("should remove all elements in the array") {
                    removeOp(false)
                }
                
                it("should signal a `RemoveAll` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.removeAll(false)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(false))
                        }
                    )
                }
            }
        }
        
        describe("#[]") {
            
            it("returns the element at the given position") {
                expect(reactiveArray[2]).to(equal(3))
            }
        }
        
        describe("#[]=") {
            
            context("when there is a value at the given position") {
                
                it("replaces the old value with the new one") {
                    reactiveArray[1] = 5
                    
                    expect(reactiveArray[1]).to(equal(5))
                }
                
                it("signals an `.Replace` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray[1] = 5
                        },
                        onReplace: { (boxedValue, index) in
                            expect(boxedValue.value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
        }
        
        describe("#mirror") {
            
            var mirror: ReactiveArray<Int>!
            
            beforeEach {
                mirror = reactiveArray.mirror { $0 + 10 }
            }
            
            it("returns a new reactive array that maps the values of the original array") {
                expect(mirror.array).to(equal([11, 12, 13, 14]))
            }
            
            context("when a `.Replace` is executed on the original array") {
                
                it("signals a mapped `.Replace` operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray[1] = 5
                        },
                        onReplace: { (boxedValue, index) in
                            expect(boxedValue.value).to(equal(15))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
            context("when an append is executed on the original array") {
                
                it("signals a mapped append operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.append(5)
                        },
                        onAppend: { boxedValue in
                            expect(boxedValue.value).to(equal(15))
                        }
                    )
                }
                
            }
            
            context("when a delete is executed on the original array") {
                
                it("signals a mapped delete operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.removeAtIndex(1)
                        },
                        onDelete: { index in
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
        }
        
        describe("#producer") {
            
            context("when the array has elements") {
                
                it("signals an append operation for each stored element") {
                    waitUntil { done in
                        // This is needed to avoid a compiler error.
                        // Probably a Swift bug
                        // TODO: Check is this is still necessary in Swift 2.0
                        let internalDone = done
                        
                        reactiveArray.producer
                            |> take(reactiveArray.count)
                            |> collect
                            |> start(next: { operations in
                                let expectedOperations: [Operation<Int>] = map(reactiveArray) { Operation.Append(value: Box($0)) }
                                let result = operations == expectedOperations
                                expect(result).to(beTrue())
                                internalDone()
                            })
                    }
                }
                
            }
            
            context("when an append operation is executed in the original array") {
                
                it("forwards the operation") {
                    let a = ReactiveArray<Int>()
                    
                    waitForOperation(
                        fromProducer: a.producer,
                        when: {
                            a.append(5)
                        },
                        onAppend: { boxedValue in
                            expect(boxedValue.value).to(equal(5))
                        }
                    )
                }
                
            }
            
            context("when an `.Replace` operation is executed in the original array") {
                
                it("forwards the operation") {
                    let a = ReactiveArray<Int>(elements: [1])
                    
                    waitForOperation(
                        fromProducer: a.producer |> skip(1), // Skips the operation triggered due to the array not being empty
                        when: {
                            a.replace(5, atIndex: 0)
                        },
                        onReplace: { (boxedValue, index) in
                            expect(boxedValue.value).to(equal(5))
                            expect(index).to(equal(0))
                        }
                    )
                }
                
            }
            
            context("when a delete operation is executed in the original array") {
                
                it("forwards the operation") {
                    let a = ReactiveArray<Int>(elements: [1])
                    
                    waitForOperation(
                        fromProducer: a.producer |> skip(1), // Skips the operation triggered due to the array not being empty
                        when: {
                            a.removeAtIndex(0)
                        },
                        onDelete: { index in
                            expect(index).to(equal(0))
                        }
                    )
                }
                
            }
            
        }
        
        describe("#signal") {
            
            context("when an `.Replace` operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.replace(5, atIndex: 1)
                        },
                        onReplace: { (boxedValue, index) in
                            expect(boxedValue.value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
            context("when an append operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.append(5)
                        },
                        onAppend: { boxedValue in
                            expect(boxedValue.value).to(equal(5))
                        }
                    )
                }
                
            }
            
            context("when a delete operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.removeAtIndex(1)
                        },
                        onDelete: { index in
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
        }
        
        describe("observableCount") {
            
            var countBeforeOperation: Int!
            var producer: SignalProducer<Int, NoError>!
            
            beforeEach {
                countBeforeOperation = reactiveArray.count
                producer = reactiveArray.observableCount.producer
            }
            
            context("when an `.Replace` operation is executed") {
                
                it("does not update the count") {
                    waitUntil { done in
                        producer
                            |> take(2)
                            |> collect
                            |> start(next: { counts in
                                expect(counts).to(equal([countBeforeOperation, countBeforeOperation]))
                                done()
                            })
                        
                        reactiveArray.replace(657, atIndex: 1)
                        reactiveArray.append(656)
                    }
                }
                
            }
            
            
            context("when an append operation is executed") {
                
                it("updates the count") {
                    waitUntil { done in
                        producer
                            |> skip(1)
                            |> start(next: { count in
                            expect(count).to(equal(countBeforeOperation + 1))
                            done()
                        })
                        
                        reactiveArray.append(656)
                    }
                }
                
            }
            
            context("when a delete operation is executed") {
                
                it("updates the count") {
                    waitUntil { done in
                        producer
                            |> skip(1)
                            |> start(next: { count in
                            expect(count).to(equal(countBeforeOperation - 1))
                            done()
                        })
                        
                        reactiveArray.removeAtIndex(1)
                    }
                }
                
            }
            
        }
        
        describe("isEmpty") {
            
            context("when the array is empty") {
                
                it("returns true") {
                    expect(ReactiveArray<Int>().isEmpty).to(beTrue())
                }
                
            }
            
            context("when the array is not empty") {
                
                it("returns false") {
                    expect(reactiveArray.isEmpty).to(beFalse())
                }
                
            }
            
        }
        
        describe("count") {
            
            it("returns the amount of elements in the array") {
                expect(reactiveArray.count).to(equal(originalData.count))
            }
            
        }
        
        describe("startIndex") {
            
            context("when the array is not empty") {

                it("returns the index of the first element") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
            context("when the array is empty") {
                
                beforeEach {
                    reactiveArray = ReactiveArray<Int>()
                }
                
                it("returns the index of the first element") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
        }
        
        describe("endIndex") {
            
            context("when the array is not empty") {
                
                it("returns the index of the last element plus one") {
                    expect(reactiveArray.endIndex).to(equal(reactiveArray.count))
                }
                
            }
            
            context("when the array is empty") {
                
                beforeEach {
                    reactiveArray = ReactiveArray<Int>()
                }
                
                it("returns zero") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
        }
        
        describe("first") {
            
            it("returns the first element in the array") {
                expect(reactiveArray.first).to(equal(originalData[0]))
            }
            
            context("when the array is empty") {
                it("should return nil") {
                    reactiveArray = ReactiveArray()
                    expect(reactiveArray.first).to(beNil())
                }
            }
        }
        
        describe("last") {
            
            it("returns the last element in the array") {
                expect(reactiveArray.last).to(equal(4))
            }
            
            context("when the array is empty") {
                it("should return nil") {
                    reactiveArray = ReactiveArray()
                    expect(reactiveArray.last).to(beNil())
                }
            }
        }
        
    }
    
}
