//
//  UICollectionView+Register.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit

extension UICollectionView {
    
    func register<CellType: UICollectionViewCell>(_ type: CellType.Type) {
        self.register(type.self, forCellWithReuseIdentifier: "\(type.self)")
    }
    
}
