//
//  Double+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit

extension Double {
    var currency: String {
        return String(format: "$%.02f", self)
    }
}
