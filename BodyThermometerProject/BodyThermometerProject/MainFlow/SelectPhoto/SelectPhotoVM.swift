//
//  SelectPhotoVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import Foundation
import RxSwift

protocol SelectPhotoRouterProtocol {
    func openGallery()
    func openCamera()
    func dismiss()
}

final class SelectPhotoVM: SelectPhotoViewModelProtocol {
    
    //In
    var closeTapped: PublishSubject<Void> = .init()
    var uploadFromGalleryTapped: PublishSubject<Void> = .init()
    var openCameraTapped: PublishSubject<Void> = .init()
    
    private let router: SelectPhotoRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: SelectPhotoRouterProtocol) {
        self.router = router
        bind()
    }
    
    private func bind() {
        closeTapped
            .subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        
        uploadFromGalleryTapped
            .subscribe(onNext: { [weak self] in
            self?.router.openGallery()
        })
        .disposed(by: bag)
        
        openCameraTapped
            .subscribe(onNext: { [weak self] in
            self?.router.openCamera()
        })
        .disposed(by: bag)
    }
    
}
