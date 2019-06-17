//
//  MainViewModel.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

struct MainViewModel {
    let navigator: MainNavigatorType
    let useCase: MainUseCaseType
}

// MARK: - ViewModelType
extension MainViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
    }

    struct Output {
        let error: Driver<Error>
        let loading: Driver<Bool>
        let reloading: Driver<Bool>
        let fetchItems: Driver<Void>
        let productList: Driver<[Product]>
    }

    func transform(_ input: Input) -> Output {
        let configOutput = configPagination(
            loadTrigger: input.loadTrigger,
            getItems: useCase.getProductList,
            reloadTrigger: input.reloadTrigger,
            reloadItems: useCase.getProductList
        )
        
        let (page, fetchItems, loadError, loading, reloading) = configOutput
        
        let productList = page
            .map { $0.items.map { $0 } }
            .asDriverOnErrorJustComplete()
        
        return Output(error: loadError,
                      loading: loading,
                      reloading: reloading,
                      fetchItems: fetchItems,
                      productList: productList)
        
    }
}
