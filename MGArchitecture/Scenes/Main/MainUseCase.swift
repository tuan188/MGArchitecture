//
//  MainUseCase.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift

protocol MainUseCaseType {
    func getProductList() -> Observable<PagingInfo<Product>>
}

struct MainUseCase: MainUseCaseType {
    func getProductList() -> Observable<PagingInfo<Product>> {
        let products = [
            Product()
        ]
        return Observable.just(PagingInfo(page: 1, items: products))
    }
}
