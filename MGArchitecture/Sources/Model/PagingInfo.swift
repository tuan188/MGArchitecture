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
    public var canLoadmore: Bool
    
    public init(page: Int, items: [T], canLoadmore: Bool) {
        self.page = page
        self.items = items
        self.canLoadmore = canLoadmore
    }
    
    public init(page: Int, items: [T]) {
        self.init(page: page, items: items, canLoadmore: true)
    }
}
