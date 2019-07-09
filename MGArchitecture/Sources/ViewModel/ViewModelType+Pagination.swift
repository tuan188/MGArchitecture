//
//  ViewModelType+Pagination.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 6/17/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension ViewModelType {
    
    public func configPagination<Item, Input, MappedItem>(
        loadTrigger: Driver<Input>,
        getItems: @escaping (Input) -> Observable<PagingInfo<Item>>,
        reloadTrigger: Driver<Input>,
        reloadItems: @escaping (Input) -> Observable<PagingInfo<Item>>,
        loadMoreTrigger: Driver<Input>,
        loadMoreItems: @escaping (Input, Int) -> Observable<PagingInfo<Item>>,
        mapper: @escaping (Item) -> MappedItem)
        ->
        (page: BehaviorRelay<PagingInfo<MappedItem>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>,
        isLoadingMore: Driver<Bool>) {
            
            let pageSubject = BehaviorRelay<PagingInfo<MappedItem>>(value: PagingInfo<MappedItem>(page: 1, items: []))
            let errorTracker = ErrorTracker()
            let loadingActivityIndicator = ActivityIndicator()
            let reloadingActivityIndicator = ActivityIndicator()
            let loadingMoreActivityIndicator = ActivityIndicator()
            
            let loading = loadingActivityIndicator.asDriver()
            let reloading = reloadingActivityIndicator.asDriver()
            let loadingMoreSubject = PublishSubject<Bool>()
            let loadingMore = Driver.merge(loadingMoreActivityIndicator.asDriver(),
                                           loadingMoreSubject.asDriverOnErrorJustComplete())
            
            let loadingOrLoadingMore = Driver.merge(loading, reloading, loadingMore)
                .startWith(false)
            
            let loadItems = loadTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .flatMapLatest { arg in
                    getItems(arg)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    let newPage = PagingInfo<MappedItem>(page: page.page,
                                                         items: page.items.map(mapper))
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let reloadItems = reloadTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .flatMapLatest { arg in
                    reloadItems(arg)
                        .trackError(errorTracker)
                        .trackActivity(reloadingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    let newPage = PagingInfo<MappedItem>(page: page.page,
                                                         items: page.items.map(mapper))
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let loadMoreItems = loadMoreTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .do(onNext: { _ in
                    if pageSubject.value.items.isEmpty {
                        loadingMoreSubject.onNext(false)
                    }
                })
                .filter { _ in !pageSubject.value.items.isEmpty }
                .flatMapLatest { arg -> Driver<PagingInfo<Item>> in
                    let page = pageSubject.value.page
                    return loadMoreItems(arg, page + 1)
                        .trackError(errorTracker)
                        .trackActivity(loadingMoreActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty || !$0.hasMorePages }
                .do(onNext: { page in
                    let currentPage = pageSubject.value
                    let items = currentPage.items + page.items.map(mapper)
                    let newPage = PagingInfo<MappedItem>(page: page.page,
                                                         items: items,
                                                         hasMorePages: page.hasMorePages)
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let fetchItems = Driver.merge(loadItems, reloadItems, loadMoreItems)
            
            return (pageSubject,
                    fetchItems,
                    errorTracker.asDriver(),
                    loading,
                    reloading,
                    loadingMore)
    }
    
    public func configPagination<Item>(loadTrigger: Driver<Void>,
                                       getItems: @escaping () -> Observable<PagingInfo<Item>>,
                                       reloadTrigger: Driver<Void>,
                                       reloadItems: @escaping () -> Observable<PagingInfo<Item>>,
                                       loadMoreTrigger: Driver<Void>,
                                       loadMoreItems: @escaping (Int) -> Observable<PagingInfo<Item>>)
        ->
        (page: BehaviorRelay<PagingInfo<Item>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>,
        isLoadingMore: Driver<Bool>) {
            
            return configPagination(
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return reloadItems()
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return loadMoreItems(page)
                },
                mapper: { $0 })
    }
    
    public func configPagination<Item>(loadTrigger: Driver<Void>,
                                       reloadTrigger: Driver<Void>,
                                       getItems: @escaping () -> Observable<PagingInfo<Item>>,
                                       loadMoreTrigger: Driver<Void>,
                                       loadMoreItems: @escaping (Int) -> Observable<PagingInfo<Item>>)
        ->
        (page: BehaviorRelay<PagingInfo<Item>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>,
        isLoadingMore: Driver<Bool>) {
            
            return configPagination(
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems()
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return loadMoreItems(page)
                },
                mapper: { $0 })
    }
    
    public func configPagination<Item>(loadTrigger: Driver<Void>,
                                       getItems: @escaping () -> Observable<PagingInfo<Item>>,
                                       reloadTrigger: Driver<Void>,
                                       reloadItems: @escaping () -> Observable<PagingInfo<Item>>)
        ->
        (page: BehaviorRelay<PagingInfo<Item>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>) {
            
            let result = configPagination(
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return reloadItems()
                },
                loadMoreTrigger: Driver.empty(),
                loadMoreItems: { _, _ in
                    return Observable.empty()
                },
                mapper: { $0 }
            )
            
            return (result.page, result.fetchItems, result.error, result.isLoading, result.isReloading)
    }
    
    public func configPagination<Item>(loadTrigger: Driver<Void>,
                                       reloadTrigger: Driver<Void>,
                                       getItems: @escaping () -> Observable<PagingInfo<Item>>)
        ->
        (page: BehaviorRelay<PagingInfo<Item>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>) {
            
            let result = configPagination(
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
            
            return (result.page, result.fetchItems, result.error, result.isLoading, result.isReloading)
    }
    
    public func configPagination<Item>(loadTrigger: Driver<Void>,
                                       reloadTrigger: Driver<Void>,
                                       loadMoreTrigger: Driver<Void>,
                                       getItems: @escaping (Int) -> Observable<PagingInfo<Item>>)
        ->
        (page: BehaviorRelay<PagingInfo<Item>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        isLoading: Driver<Bool>,
        isReloading: Driver<Bool>,
        isLoadingMore: Driver<Bool>) {
            
            return configPagination(
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
}
