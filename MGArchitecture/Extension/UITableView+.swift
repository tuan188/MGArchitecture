//
//  UITableView+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/23/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UITableView {
    var isEmpty: Binder<Bool> {
        return Binder(self) { tableView, isEmpty in
            if isEmpty {
                let frame = CGRect(x: 0,
                                   y: 0,
                                   width: tableView.frame.size.width,
                                   height: tableView.frame.size.height)
                let emptyView = EmptyDataView(frame: frame)
                tableView.backgroundView = emptyView
            } else {
                tableView.backgroundView = nil
            }
        }
    }
}
