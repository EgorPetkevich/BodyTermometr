//
//  BPMStatusView+Rx.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import RxSwift
import RxCocoa

extension Reactive where Base: BPMStatusView {
    /// Bind a computed BPMStatus to update text and color
    var status: Binder<BPMStatus> {
        Binder(base) { view, status in
            view.bmpStatusLabel.text = status.title
            view.backgroundColor = status.color
        }
    }

    /// Bind a raw BPM (Int). It will be mapped to BPMStatus under the hood
    var bpmStatus: Binder<Int> {
        Binder(base) { view, bpm in
            let status = BPMStatus(bpm: bpm)
            view.bmpStatusLabel.text = status.title
            view.backgroundColor = status.color
        }
    }
}
