//
//  SelectPhotoRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift

final class SelectPhotoRouter: SelectPhotoRouterProtocol {
    
    weak var root: UIViewController?
    
    private var openGallerySubject: PublishSubject<Void>
    private var openCameraSubject: PublishSubject<Void>
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
    init(openGallerySubject: PublishSubject<Void>,
         openCameraSubject: PublishSubject<Void>) {
        self.openGallerySubject = openGallerySubject
        self.openCameraSubject = openCameraSubject
    }
    
    func openGallery() {
        openGallerySubject.onNext(())
        root?.dismiss(animated: true)
    }
    
    func openCamera() {
        openCameraSubject.onNext(())
        root?.dismiss(animated: true)
    }
    
}
