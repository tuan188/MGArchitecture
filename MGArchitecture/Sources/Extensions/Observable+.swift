//
//  Observable+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    public func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
    
    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    public func mapToOptional() -> Observable<Element?> {
        return map { value -> Element? in value }
    }
    
    public func unwrap<T>() -> Observable<T> where Element == T? {
        return self
            .flatMap { Observable.from(optional: $0) }
    }
}

extension SharedSequenceConvertibleType {
    
    public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
    
    public func mapToOptional() -> SharedSequence<SharingStrategy, Element?> {
        return map { value -> Element? in value }
    }
    
    public func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
        return self
            .flatMap { SharedSequence.from(optional: $0) }
    }
}

extension ObservableType where Element == Bool {
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension SharedSequenceConvertibleType where Element == Bool {
    public func not() -> SharedSequence<SharingStrategy, Bool> {
        return self.map(!)
    }
}

fileprivate func getThreadName() -> String {
    if Thread.current.isMainThread {
        return "Main Thread"
    } else if let name = Thread.current.name {
        if name == "" {
            return "Anonymous Thread"
        }
        return name
    } else {
        return "Unknown Thread"
    }
}

extension ObservableType {
    public func dump() -> Observable<Self.Element> {
        return self.do(onNext: { element in
            let threadName = getThreadName()
            print("[D] \(element) received on \(threadName)")
        })
    }
    
    public func dumpingSubscription() -> Disposable {
        return self.subscribe(onNext: { element in
            let threadName = getThreadName()
            print("[S] \(element) received on \(threadName)")
        })
    }
}

