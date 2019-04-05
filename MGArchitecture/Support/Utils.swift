//
//  Utils.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/4/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit

func after(interval: TimeInterval, completion: (() -> Void)?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
        completion?()
    }
}
