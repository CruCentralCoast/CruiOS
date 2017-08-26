//
//  UITableView+Additions.swift
//  Cru
//
//  Created by Tyler Dahl on 8/21/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

extension UITableView {
    func registerCell(_ cellClass: UITableViewCell.Type) {
        self.register(cellClass, forCellReuseIdentifier: cellClass.cellReuseIdentifier)
    }
    
    func registerNib(_ cellClass: UITableViewCell.Type) {
        let nib = UINib(nibName: cellClass.className, bundle: nil)
        self.register(nib, forCellReuseIdentifier: cellClass.cellReuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: cellClass.cellReuseIdentifier, for: indexPath) as! T
    }
}
