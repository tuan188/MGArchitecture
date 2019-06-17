//
//  MainViewController.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable

final class MainViewController: UIViewController, BindableType {
    
    // MARK: - IBOutlets
    
    // MARK: - Properties
    
    var viewModel: MainViewModel!

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
        
    }

    func bindViewModel() {
//        let input = MainViewModel.Input()
//        _ = viewModel.transform(input)
    }
}

// MARK: - Binders
extension MainViewController {

}

// MARK: - StoryboardSceneBased
extension MainViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
