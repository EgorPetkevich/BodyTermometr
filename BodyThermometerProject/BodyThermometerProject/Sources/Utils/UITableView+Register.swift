//
//  UITableView+Register.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import UIKit

extension UITableView {
    
    func register<CellType: UITableViewCell>(_ type: CellType.Type) {
        self.register(type.self, forCellReuseIdentifier: "\(type.self)")
    }
    
    func dequeue<CellType: UITableViewCell>(
        at indexPath: IndexPath
    ) -> CellType {
        return self.dequeueReusableCell(withIdentifier:"\(CellType.self)",
                                        for: indexPath) as! CellType
    }
    
}
