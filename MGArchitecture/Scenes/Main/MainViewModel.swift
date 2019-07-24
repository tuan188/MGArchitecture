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
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let productList: Driver<[Product]>
    }

    func transform(_ input: Input) -> Output {
        let result = configPagination(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getProductList
        )
        
        let productList = result.page
            .map { $0.items.map { $0 } }
        
        return Output(error: result.error,
                      isLoading: result.isLoading,
                      isReloading: result.isReloading,
                      productList: productList)
        
    }
}
