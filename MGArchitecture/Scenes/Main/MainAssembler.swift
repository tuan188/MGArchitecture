//
//  MainAssembler.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit

protocol MainAssembler {
    func resolve(navigationController: UINavigationController) -> MainViewController
    func resolve(navigationController: UINavigationController) -> MainViewModel
    func resolve(navigationController: UINavigationController) -> MainNavigatorType
    func resolve() -> MainUseCaseType
}

extension MainAssembler {
    func resolve(navigationController: UINavigationController) -> MainViewController {
        let vc = MainViewController.instantiate()
        let vm: MainViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController) -> MainViewModel {
        return MainViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension MainAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> MainNavigatorType {
        return MainNavigator(assembler: self, navigationController: navigationController)
    }

    func resolve() -> MainUseCaseType {
        return MainUseCase()
    }
}