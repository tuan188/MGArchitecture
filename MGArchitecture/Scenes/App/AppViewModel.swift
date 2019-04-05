//
//  AppViewModel.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//
import RxCocoa

struct AppViewModel {
    let navigator: AppNavigatorType
    let useCase: AppUseCaseType
}

// MARK: - ViewModelType
extension AppViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let toMain: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let toMain = input.loadTrigger
            .do(onNext: { _ in
                self.navigator.toMain()
            })
        
        return Output(toMain: toMain)
    }
}
