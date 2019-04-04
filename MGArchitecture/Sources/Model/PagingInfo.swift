//
//  PagingInfo.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public struct PagingInfo<T> {
    public let page: Int
    public let items: [T]
    
    public init(page: Int, items: [T]) {
        self.page = page
        self.items = items
    }
}
