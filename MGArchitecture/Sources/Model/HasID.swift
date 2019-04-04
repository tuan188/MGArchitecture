//
//  HasID.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public protocol HasID {
    associatedtype IDType
    var id: IDType { get }
}

extension Hashable where Self: HasID, Self.IDType == Int {
    public var hashValue: Int {
        return id
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Hashable where Self: HasID, Self.IDType == String {
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
