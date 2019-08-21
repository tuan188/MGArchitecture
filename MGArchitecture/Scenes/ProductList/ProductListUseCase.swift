//
//  ProductListUseCase.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift

protocol ProductListUseCaseType {
    func getProductList(query: String, page: Int) -> Observable<PagingInfo<Product>>
    func getProductList(page: Int) -> Observable<PagingInfo<Product>>
    func getEmptyProductList(page: Int) -> Observable<PagingInfo<Product>>
    func getProductList() -> Observable<[Product]>
    func getProduct(query: String) -> Observable<Product>
}

struct ProductListUseCase: ProductListUseCaseType {
    func getProductList(query: String, page: Int) -> Observable<PagingInfo<Product>> {
        return getProductList(page: page)
    }
    
    func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
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
    
    func getEmptyProductList(page: Int) -> Observable<PagingInfo<Product>> {
        return Observable.create { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                let page = PagingInfo<Product>(page: page, items: [])
                observer.onNext(page)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func getProductList() -> Observable<[Product]> {
        return Observable.create { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                let products = Array(0...9)
                    .map { id in
                        Product().with {
                            $0.id = id
                            $0.name = "Product \(id)"
                            $0.price = Double(id * 2)
                        }
                    }
                observer.onNext(products)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func getProduct(query: String) -> Observable<Product> {
        return Observable.just(Product())
    }
}
