//
//  ProductViewModel.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

struct ProductViewModel {
    let product: Product
    
    var name: String {
        return product.name
    }
        
    var price: String {
        return product.price.currency
    }
}
