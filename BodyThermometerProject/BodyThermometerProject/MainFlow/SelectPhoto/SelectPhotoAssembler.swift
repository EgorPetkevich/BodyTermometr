//
//  SelectPhotoAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift

final class SelectPhotoAssembler {
    
    private init() {}
    
    static func assembly(openGallerySubject: PublishSubject<Void>,
                         openCameraSubject: PublishSubject<Void>) -> UIViewController {
        let router = SelectPhotoRouter(openGallerySubject: openGallerySubject,
                                       openCameraSubject: openCameraSubject)
        let viewModel = SelectPhotoVM(router: router)
        let viewController = SelectPhotoVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}
