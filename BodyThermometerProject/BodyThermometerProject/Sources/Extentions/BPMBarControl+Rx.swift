//
//  BPMBarControl+Rx.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import RxSwift
import RxCocoa

extension Reactive where Base: BPMBarControl {
    /// Take bpm (Int) and update trackView
    var bpm: Binder<Int> {
        Binder(base) { view, bpm in
            view.setBPM(bpm, animated: true)
        }
    }
}
