//
//  ProductListUseCase.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift

protocol ProductListUseCaseType {
    func getProductList(page: Int) -> Observable<PagingInfo<Product>>
}

struct ProductListUseCase: ProductListUseCaseType {
    func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
//        return Observable.create { observer in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
//                let page = PagingInfo<Product>(page: page, items: [])
//                observer.onNext(page)
//                observer.onCompleted()
//            })
//            return Disposables.create()
//        }
        
        return Observable.create { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                let products = Array(0...9)
                    .map { $0 + (page - 1) * 10 }
                    .map { id in
                        Product().with {
                            $0.id = id
                            $0.name = "Product \(id)"
                            $0.price = Double(id * 2)
                        }
                    }
                let page = PagingInfo<Product>(page: page, items: products)
                observer.onNext(page)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
