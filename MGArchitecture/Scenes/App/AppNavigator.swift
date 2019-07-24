//
//  AppNavigator.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit

protocol AppNavigatorType {
    func toMain()
    func toProductList()
}

struct AppNavigator: AppNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow
    
    func toMain() {
        let nav = UINavigationController()
        let vc: MainViewController = assembler.resolve(navigationController: nav)
        nav.viewControllers = [vc]
        window.rootViewController = nav
    }
    
    func toProductList() {
        let nav = UINavigationController()
        let vc: ProductListViewController = assembler.resolve(navigationController: nav)
        nav.viewControllers = [vc]
        window.rootViewController = nav
    }
}
