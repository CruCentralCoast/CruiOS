//
//  DequeueExtensions.swift
//  SpiceForecast
//
// These extensions contain functions that guarantee to either give you a cell of the correct type or cause a fatalError.
//
//  Created by Michael Cantrell on 8/23/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

public extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_ cellType: T.Type){
        self.register(UINib(nibName: String(describing: cellType.self), bundle: nil), forCellWithReuseIdentifier: String(describing: cellType.self))
    }
    
    func dequeueCell<T: UICollectionViewCell>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        let reuseID = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as? T else {
            fatalError("The dequeued cell is not an instance of \(reuseID).")
        }
        return cell
    }
}

public extension UITableView {
    func registerCell<T: UITableViewCell>(_ cellType: T.Type){
        self.register(UINib(nibName: String(describing: cellType.self), bundle: nil), forCellReuseIdentifier: String(describing: cellType.self))
    }
    
    func dequeueCell<T: UITableViewCell>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        let reuseID = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as? T else {
            fatalError("The dequeued cell is not an instance of \(reuseID).")
        }
        return cell
    }
}
