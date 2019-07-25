//
//  ViewModelType+GetList.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/25/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

public struct GetListResult<T> {
    public var items: Driver<[T]>
    public var error: Driver<Error>
    public var isLoading: Driver<Bool>
    public var isReloading: Driver<Bool>
    
    public var destructured: (Driver<[T]>, Driver<Error>, Driver<Bool>, Driver<Bool>) {
        return (items, error, isLoading, isReloading)
    }
    
    public init(items: Driver<[T]>,
                error: Driver<Error>,
                isLoading: Driver<Bool>,
                isReloading: Driver<Bool>) {
        self.items = items
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

extension ViewModelType {
    public func getList<Item, Input, MappedItem>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>,
        reloadTrigger: Driver<Input>,
        reloadItems: @escaping (Input) -> Observable<[Item]>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {
            
            let error = errorTracker.asDriver()
            let isLoading = pageActivityIndicator.isLoading
            let isReloading = pageActivityIndicator.isReloading
            
            let isLoadingOrReloading = Driver.merge(isLoading, isReloading)
                .startWith(false)
            
            let items = Driver<ScreenLoadingType<Input>>
                .merge(
                    loadTrigger.map { ScreenLoadingType.loading($0) },
                    reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrReloading) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<[Item]> in
                    switch triggerType {
                    case .loading(let input):
                        return getItems(input)
                            .trackError(errorTracker)
                            .trackActivity(pageActivityIndicator.loadingIndicator)
                            .asDriverOnErrorJustComplete()
                    case .reloading(let input):
                        return reloadItems(input)
                            .trackError(errorTracker)
                            .trackActivity(pageActivityIndicator.reloadingIndicator)
                            .asDriverOnErrorJustComplete()
                    }
                }
                .map { $0.map(mapper) }
            
            return GetListResult(
                items: items,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading
            )
    }
    
    public func getList<Item, Input, MappedItem>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {
            
            return getList(
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: mapper)
    }
    
    public func getList<Item, Input, MappedItem>(
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {
            
            return getList(
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: mapper)
    }
    
    public func getList<Item, Input>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>)
        -> GetListResult<Item> {
            
            return getList(
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: { $0 })
    }
    
    public func getList<Item, Input>(
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>)
        -> GetListResult<Item> {
            
            return getList(
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: { $0 })
    }
    
    public func getList<Item>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        getItems: @escaping () -> Observable<[Item]>)
        -> GetListResult<Item> {
            
            return getList(
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems()
                },
                mapper: { $0 })
    }
    
    public func getList<Item>(
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        getItems: @escaping () -> Observable<[Item]>)
        -> GetListResult<Item> {
            
            return getList(
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems()
                },
                mapper: { $0 })
    }
}

