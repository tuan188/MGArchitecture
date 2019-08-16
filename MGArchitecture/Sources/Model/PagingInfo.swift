//
//  PagingInfo.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public struct PagingInfo<T> {
    public var page: Int
    public var items: [T]
    public var hasMorePages: Bool
    
    public init(page: Int, items: [T], hasMorePages: Bool) {
        self.page = page
        self.items = items
        self.hasMorePages = hasMorePages
    }
    
    public init(page: Int, items: [T]) {
        self.init(page: page, items: items, hasMorePages: true)
    }
    
    public init() {
        self.init(page: 1, items: [], hasMorePages: true)
    }
}
