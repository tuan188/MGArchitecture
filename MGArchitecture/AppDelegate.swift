//
//  AppDelegate.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var assembler: Assembler = DefaultAssembler()
    var disposeBag = DisposeBag()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        if NSClassFromString("XCTest") != nil { // test
            window?.rootViewController = UnitTestViewController()
        } else {
            bindViewModel()
        }
    }

    private func bindViewModel() {
        guard let window = window else { return }
        
        let vm: AppViewModel = assembler.resolve(window: window)
        let input = AppViewModel.Input(loadTrigger: Driver.just(()))
        _ = vm.transform(input, disposeBag: disposeBag)
    }
}
