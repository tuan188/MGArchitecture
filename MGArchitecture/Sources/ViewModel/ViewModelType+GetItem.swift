//
//  ViewModelType+GetItem.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/26/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

public struct GetItemResult<T> {
    public var item: Driver<T>
    public var error: Driver<Error>
    public var isLoading: Driver<Bool>
    public var isReloading: Driver<Bool>
    
    public var destructured: (Driver<T>, Driver<Error>, Driver<Bool>, Driver<Bool>) {
        return (item, error, isLoading, isReloading)
    }
    
    public init(item: Driver<T>,
                error: Driver<Error>,
                isLoading: Driver<Bool>,
                isReloading: Driver<Bool>) {
        self.item = item
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

extension ViewModelType {
    public func getItem<Item, Input>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        getItem: @escaping (Input) -> Observable<Item>,
        reloadTrigger: Driver<Input>,
        reloadItem: @escaping (Input) -> Observable<Item>)
        -> GetItemResult<Item> {
            
            let error = errorTracker.asDriver()
            let isLoading = pageActivityIndicator.isLoading
            let isReloading = pageActivityIndicator.isReloading
            
            let isLoadingOrReloading = Driver.merge(isLoading, isReloading)
                .startWith(false)
            
            let item = Driver<ScreenLoadingType<Input>>
                .merge(
                    loadTrigger.map { ScreenLoadingType.loading($0) },
                    reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrReloading) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<Item> in
                    switch triggerType {
                    case .loading(let input):
                        return getItem(input)
                            .trackError(errorTracker)
                            .trackActivity(pageActivityIndicator.loadingIndicator)
                            .asDriverOnErrorJustComplete()
                    case .reloading(let input):
                        return reloadItem(input)
                            .trackError(errorTracker)
                            .trackActivity(pageActivityIndicator.reloadingIndicator)
                            .asDriverOnErrorJustComplete()
                    }
                }
            
            return GetItemResult(
                item: item,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading
            )
    }
    
    public func getItem<Item, Input>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItem: @escaping (Input) -> Observable<Item>)
        -> GetItemResult<Item> {
            
            return self.getItem(
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItem: getItem,
                reloadTrigger: reloadTrigger,
                reloadItem: getItem
            )
    }
    
    public func getItem<Item, Input>(
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItem: @escaping (Input) -> Observable<Item>)
        -> GetItemResult<Item> {
            
            return self.getItem(
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItem: getItem,
                reloadTrigger: reloadTrigger,
                reloadItem: getItem
            )
    }
}
