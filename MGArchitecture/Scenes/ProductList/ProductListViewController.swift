//
//  ProductListViewController.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import NSObject_Rx
import MGLoadMore

final class ProductListViewController: UIViewController, BindableType {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: LoadMoreTableView!

    // MARK: - Properties

    var viewModel: ProductListViewModel!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    deinit {
        logDeinit()
    }

    // MARK: - Methods

    private func configView() {
        tableView.do {
            $0.rowHeight = 80
            $0.register(cellType: ProductCell.self)
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = ProductListViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: tableView.refreshTrigger,
            loadMoreTrigger: tableView.loadMoreTrigger,
            selectProductTrigger: tableView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input)

        output.productList
            .drive(tableView.rx.items) { tableView, index, product in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: ProductCell.self)
                    .then {
                        $0.bindViewModel(ProductViewModel(product: product))
                    }
            }
            .disposed(by: rx.disposeBag)

        output.error
            .drive()
            .disposed(by: rx.disposeBag)

        output.isLoading
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)

        output.isReloading
            .drive(tableView.isRefreshing)
            .disposed(by: rx.disposeBag)

        output.isLoadingMore
            .drive(tableView.isLoadingMore)
            .disposed(by: rx.disposeBag)

        output.selectedProduct
            .drive(onNext: { product in
                print(product.name)
            })
            .disposed(by: rx.disposeBag)

        output.isEmpty
            .do(onNext: { isEmpty in
                print("is empty = ", isEmpty)
            })
            .drive(tableView.isEmpty)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Binders
extension ProductListViewController {

}

// MARK: - UITableViewDelegate
extension ProductListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension ProductListViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
