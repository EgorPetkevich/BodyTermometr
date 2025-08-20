//
//  Reactive+UIViewController.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

    func hideKeyboardOnTap(disposeBag: DisposeBag) {
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        base.view.addGestureRecognizer(tap)

        tap.rx.event
            .bind { [weak base] _ in
                base?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}
