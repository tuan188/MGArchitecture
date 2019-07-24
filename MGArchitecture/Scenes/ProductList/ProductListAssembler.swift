//
//  ProductListAssembler.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit

protocol ProductListAssembler {
    func resolve(navigationController: UINavigationController) -> ProductListViewController
    func resolve(navigationController: UINavigationController) -> ProductListViewModel
    func resolve(navigationController: UINavigationController) -> ProductListNavigatorType
    func resolve() -> ProductListUseCaseType
}

extension ProductListAssembler {
    func resolve(navigationController: UINavigationController) -> ProductListViewController {
        let vc = ProductListViewController.instantiate()
        let vm: ProductListViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController) -> ProductListViewModel {
        return ProductListViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension ProductListAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> ProductListNavigatorType {
        return ProductListNavigator(assembler: self, navigationController: navigationController)
    }

    func resolve() -> ProductListUseCaseType {
        return ProductListUseCase()
    }
}