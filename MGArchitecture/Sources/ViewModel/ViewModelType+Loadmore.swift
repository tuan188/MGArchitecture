//
//  ViewModelType+Loadmore.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension ViewModelType {
    public func setupLoadMorePaging<T>(loadTrigger: Driver<Void>,
                                getItems: @escaping () -> Observable<PagingInfo<T>>,
                                refreshTrigger: Driver<Void>,
                                refreshItems: @escaping () -> Observable<PagingInfo<T>>,
                                loadMoreTrigger: Driver<Void>,
                                loadMoreItems: @escaping (Int) -> Observable<PagingInfo<T>>)
        ->
        (page: BehaviorRelay<PagingInfo<T>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
                
            return setupLoadMorePagingWithParam(
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                refreshTrigger: refreshTrigger,
                refreshItems: { _ in
                    return refreshItems()
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return loadMoreItems(page)
                },
                mapper: { $0 }
            )
    }
    
    public func setupLoadMorePaging<T, V>(loadTrigger: Driver<Void>,
                                   getItems: @escaping () -> Observable<PagingInfo<T>>,
                                   refreshTrigger: Driver<Void>,
                                   refreshItems: @escaping () -> Observable<PagingInfo<T>>,
                                   loadMoreTrigger: Driver<Void>,
                                   loadMoreItems: @escaping (Int) -> Observable<PagingInfo<T>>,
                                   mapper: @escaping (T) -> V)
        ->
        (page: BehaviorRelay<PagingInfo<V>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
            
            return setupLoadMorePagingWithParam(
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                refreshTrigger: refreshTrigger,
                refreshItems: { _ in
                    return refreshItems()
                },
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: { _, page in
                    return loadMoreItems(page)
                },
                mapper: mapper)
    }

    public func setupLoadMorePagingWithParam<T, U>(loadTrigger: Driver<U>,
                                            getItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                            refreshTrigger: Driver<U>,
                                            refreshItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                            loadMoreTrigger: Driver<U>,
                                            loadMoreItems: @escaping (U, Int) -> Observable<PagingInfo<T>>)
        ->
        (page: BehaviorRelay<PagingInfo<T>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
            
            return setupLoadMorePagingWithParam(
                loadTrigger: loadTrigger,
                getItems: getItems,
                refreshTrigger: refreshTrigger,
                refreshItems: refreshItems,
                loadMoreTrigger: loadMoreTrigger,
                loadMoreItems: loadMoreItems,
                mapper: { $0 }
            )
    }
    
    public func setupLoadMorePagingWithParam<T, U, V>(loadTrigger: Driver<U>,
                                               getItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                               refreshTrigger: Driver<U>,
                                               refreshItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                               loadMoreTrigger: Driver<U>,
                                               loadMoreItems: @escaping (U, Int) -> Observable<PagingInfo<T>>,
                                               mapper: @escaping (T) -> V)
        ->
        (page: BehaviorRelay<PagingInfo<V>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
            
            let pageSubject = BehaviorRelay<PagingInfo<V>>(value: PagingInfo<V>(page: 1, items: []))
            let errorTracker = ErrorTracker()
            let loadingActivityIndicator = ActivityIndicator()
            let refreshingActivityIndicator = ActivityIndicator()
            let loadingMoreActivityIndicator = ActivityIndicator()
            
            let loading = loadingActivityIndicator.asDriver()
            let refreshing = refreshingActivityIndicator.asDriver()
            let loadingMoreSubject = PublishSubject<Bool>()
            let loadingMore = Driver.merge(loadingMoreActivityIndicator.asDriver(),
                                           loadingMoreSubject.asDriverOnErrorJustComplete())
            
            let loadingOrLoadingMore = Driver.merge(loading, refreshing, loadingMore)
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
                    let newPage = PagingInfo<V>(page: page.page,
                                                items: page.items.map(mapper))
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let refreshItems = refreshTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .flatMapLatest { arg in
                    refreshItems(arg)
                        .trackError(errorTracker)
                        .trackActivity(refreshingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    let newPage = PagingInfo<V>(page: page.page,
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
                .flatMapLatest { arg -> Driver<PagingInfo<T>> in
                    let page = pageSubject.value.page
                    return loadMoreItems(arg, page + 1)
                        .trackError(errorTracker)
                        .trackActivity(loadingMoreActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty }
                .do(onNext: { page in
                    let currentPage = pageSubject.value
                    let items = currentPage.items + page.items.map(mapper)
                    let newPage = PagingInfo<V>(page: page.page, items: items)
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let fetchItems = Driver.merge(loadItems, refreshItems, loadMoreItems)
            return (pageSubject,
                    fetchItems,
                    errorTracker.asDriver(),
                    loading,
                    refreshing,
                    loadingMore)
    }
}
