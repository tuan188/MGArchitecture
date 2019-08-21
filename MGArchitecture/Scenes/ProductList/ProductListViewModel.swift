//
//  ProductListViewModel.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

struct ProductListViewModel {
    let navigator: ProductListNavigatorType
    let useCase: ProductListUseCaseType
}

// MARK: - ViewModelType
extension ProductListViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let selectProductTrigger: Driver<IndexPath>
    }

    struct Output {
        let error: Driver<Error>
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let isLoadingMore: Driver<Bool>
        let productList: Driver<[Product]>
        let selectedProduct: Driver<Product>
        let isEmpty: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let getPageResult = getPage(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            loadMoreTrigger: input.loadMoreTrigger,
            getItems: useCase.getProductList)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = getPageResult.destructured

        let productList = page
            .map { $0.items.map { $0 } }

        let selectedProduct = select(trigger: input.selectProductTrigger, items: productList)
            .do(onNext: { product in
                self.navigator.toProductDetail(product: product)
            })

        let isEmpty = checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading),
                                         items: productList)

        return Output(
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            isLoadingMore: isLoadingMore,
            productList: productList,
            selectedProduct: selectedProduct,
            isEmpty: isEmpty
        )
    }
}

// MARK: - Test
extension ProductListViewModel {
    func testGetPage(_ input: Input) {
        _ = getPage(
            pageSubject: BehaviorRelay<PagingInfo<Product>>(value: PagingInfo<Product>()),
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            getItems: { input in
                return self.useCase.getProductList(query: input, page: 1)
            },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            reloadItems: { input in
                return self.useCase.getProductList(query: input, page: 1)
            },
            loadMoreTrigger: input.loadMoreTrigger.map { _ in "query" },
            loadMoreItems: useCase.getProductList(query:page:),
            mapper: { $0 }
        )
        
        _ = getPage(
            pageSubject: BehaviorRelay<PagingInfo<Product>>(value: PagingInfo<Product>()),
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            loadMoreTrigger: input.loadMoreTrigger.map { _ in "query" },
            getItems: useCase.getProductList(query:page:),
            mapper: { $0 })
        
        _ = getPage(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            loadMoreTrigger: input.loadMoreTrigger.map { _ in "query" },
            getItems: useCase.getProductList(query:page:))
        
        _ = getPage(
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            loadMoreTrigger: input.loadMoreTrigger.map { _ in "query" },
            getItems: useCase.getProductList(query:page:))
        
        _ = getPage(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            loadMoreTrigger: input.loadMoreTrigger,
            getItems: useCase.getProductList(page:))
        
        _ = getPage(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            loadMoreTrigger: input.loadMoreTrigger,
            getItems: useCase.getProductList(page:))
        
        _ = getPage(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: {
                self.useCase.getProductList(page: 1)
            })
        
        _ = getPage(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: {
                self.useCase.getProductList(page: 1)
            })
    }
    
    func testGetList(_ input: Input) {
        _ = getList(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            getItems: { _ in
                self.useCase.getProductList()
            },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            reloadItems: { _ in
                self.useCase.getProductList()
            },
            mapper: { $0 })
        
        _ = getList(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItems: { _ in
                self.useCase.getProductList()
            },
            mapper: { $0 })
        
        _ = getList(
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItems: { _ in
                self.useCase.getProductList()
            },
            mapper: { $0 })
        
        _ = getList(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItems: { _ in
                self.useCase.getProductList()
            })
        
        _ = getList(
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItems: { _ in
                self.useCase.getProductList()
            })
    }
    
    func testGetItem(_ input: Input) {
        _ = getItem(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            getItem: useCase.getProduct(query:),
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            reloadItem: useCase.getProduct(query:))
        
        _ = getItem(
            pageActivityIndicator: PageActivityIndicator(),
            errorTracker: ErrorTracker(),
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItem: useCase.getProduct(query:))
        
        _ = getItem(
            loadTrigger: input.loadTrigger.map { _ in "query" },
            reloadTrigger: input.reloadTrigger.map { _ in "query" },
            getItem: useCase.getProduct(query:))
    }
}
