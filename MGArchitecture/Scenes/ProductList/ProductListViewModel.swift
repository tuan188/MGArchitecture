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
        let paginationResult = configPagination(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            loadMoreTrigger: input.loadMoreTrigger,
            getItems: useCase.getProductList)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = paginationResult.destructured

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
