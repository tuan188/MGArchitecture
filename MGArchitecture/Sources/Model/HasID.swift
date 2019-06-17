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
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Hashable where Self: HasID, Self.IDType == String {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
