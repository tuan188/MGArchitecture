//
//  ViewModelType+Pagination.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 6/17/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

public struct PaginationResult<T> {
    public var page: Driver<PagingInfo<T>>
    public var error: Driver<Error>
    public var isLoading: Driver<Bool>
    public var isReloading: Driver<Bool>
    public var isLoadingMore: Driver<Bool>
    
    public var destructured: (Driver<PagingInfo<T>>, Driver<Error>, Driver<Bool>, Driver<Bool>, Driver<Bool>) {
        return (page, error, isLoading, isReloading, isLoadingMore)
    }
    
    public init(page: Driver<PagingInfo<T>>,
                error: Driver<Error>,
                isLoading: Driver<Bool>,
                isReloading: Driver<Bool>,
                isLoadingMore: Driver<Bool>) {
        self.page = page
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
        self.isLoadingMore = isLoadingMore
    }
}

extension ViewModelType {
    public func configPagination<Item, Input, MappedItem>(
        pageSubject: BehaviorRelay<PagingInfo<MappedItem>>,
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<PagingInfo<Item>>,
        reloadTrigger: Driver<Input>,
        reloadItems: @escaping (Input) -> Observable<PagingInfo<Item>>,
        loadMoreTrigger: Driver<Input>,
        loadMoreItems: @escaping (Input, Int) -> Observable<PagingInfo<Item>>,
        mapper: @escaping (Item) -> MappedItem)
        -> PaginationResult<MappedItem> {
            
            let error = errorTracker.asDriver()
            let isLoading = pageActivityIndicator.isLoading
            let isReloading = pageActivityIndicator.isReloading
            
            let loadingMoreSubject = PublishSubject<Bool>()
            
            let isLoadingMore = Driver.merge(
                pageActivityIndicator.isLoadingMore,
                loadingMoreSubject.asDriverOnErrorJustComplete()
            )
            
            let isLoadingOrLoadingMore = Driver.merge(isLoading, isReloading, isLoadingMore)
                .startWith(false)
            
            let loadItems = Driver<ScreenLoadingType<Input>>
                .merge(
                    loadTrigger.map { ScreenLoadingType.loading($0) },
                    reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrLoadingMore) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<PagingInfo<Item>> in
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
                .do(onNext: { page in
                    let newPage = PagingInfo<MappedItem>(
                        page: page.page,
                        items: page.items.map(mapper)
                    )
                    
                    pageSubject.accept(newPage)
                })
            
            let loadMoreItems = loadMoreTrigger
                .withLatestFrom(isLoadingOrLoadingMore) {
                    (input: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.input }
                .do(onNext: { _ in
                    if pageSubject.value.items.isEmpty {
                        loadingMoreSubject.onNext(false)
                    }
                })
                .filter { _ in !pageSubject.value.items.isEmpty }
                .flatMapLatest { input -> Driver<PagingInfo<Item>> in
                    let page = pageSubject.value.page
                    
                    return loadMoreItems(input, page + 1)
                        .trackError(errorTracker)
                        .trackActivity(pageActivityIndicator.loadingMoreIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty || !$0.hasMorePages }
                .do(onNext: { page in
                    let currentPage = pageSubject.value
                    let items = currentPage.items + page.items.map(mapper)
                    
                    let newPage = PagingInfo<MappedItem>(
                        page: page.page,
                        items: items,
                        hasMorePages: page.hasMorePages
                    )
                    
                    pageSubject.accept(newPage)
                })
            
            let page = Driver.merge(loadItems, loadMoreItems)
                .withLatestFrom(pageSubject.asDriver())
            
            return PaginationResult(
                page: page,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading,
                isLoadingMore: isLoadingMore
            )
    }
    
    public func configPagination<Item, Input, MappedItem>(
        pageSubject: BehaviorRelay<PagingInfo<MappedItem>>,
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        loadMoreTrigger: Driver<Input>,
        getItems: @escaping (Input, Int) -> Observable<PagingInfo<Item>>,
        mapper: @escaping (Item) -> MappedItem)
        -> PaginationResult<MappedItem> {
            
            return configPagination(
                pageSubject: pageSubject,
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: { input in
                    return getItems(input, 1)
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { input in
                    return getItems(input, 1)
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: getItems,
                mapper: mapper
            )
    }
    
    public func configPagination<Item, Input>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        loadMoreTrigger: Driver<Input>,
        getItems: @escaping (Input, Int) -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: { input in
                    return getItems(input, 1)
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { input in
                    return getItems(input, 1)
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: getItems,
                mapper: { $0 }
            )
    }
    
    public func configPagination<Item, Input>(
        loadTrigger: Driver<Input>,
        reloadTrigger: Driver<Input>,
        loadMoreTrigger: Driver<Input>,
        getItems: @escaping (Input, Int) -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: { input in
                    return getItems(input, 1)
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { input in
                    return getItems(input, 1)
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: getItems,
                mapper: { $0 }
            )
    }
    
    public func configPagination<Item>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        loadMoreTrigger: Driver<Void>,
        getItems: @escaping (Int) -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
                pageActivityIndicator: pageActivityIndicator,
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems(1)
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems(1)
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return getItems(page)
                },
                mapper: { $0 }
            )
    }
    
    public func configPagination<Item>(
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        loadMoreTrigger: Driver<Void>,
        getItems: @escaping (Int) -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
                pageActivityIndicator: PageActivityIndicator(),
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems(1)
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems(1)
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return getItems(page)
                },
                mapper: { $0 }
            )
    }
    
    public func configPagination<Item>(
        pageActivityIndicator: PageActivityIndicator,
        errorTracker: ErrorTracker,
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        getItems: @escaping () -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
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
                loadMoreTrigger: Driver.empty(),
                loadMoreItems: { _, _ in
                    return Observable.empty()
                },
                mapper: { $0 }
            )
    }
    
    public func configPagination<Item>(
        loadTrigger: Driver<Void>,
        reloadTrigger: Driver<Void>,
        getItems: @escaping () -> Observable<PagingInfo<Item>>)
        -> PaginationResult<Item> {
            
            let pageSubject = BehaviorRelay<PagingInfo<Item>>(
                value: PagingInfo<Item>(page: 1, items: [])
            )
            
            return configPagination(
                pageSubject: pageSubject,
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
                loadMoreTrigger: Driver.empty(),
                loadMoreItems: { _, _ in
                    return Observable.empty()
                },
                mapper: { $0 }
            )
    }
}
