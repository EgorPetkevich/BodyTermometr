//
//  ProfileRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift

final class ProfileRouter: ProfileRouterProtocol {
    
    weak var root: UIViewController?
    
    var openGallerySubject: PublishSubject<Void> = .init()
    var openCameraSubject: PublishSubject<Void> = .init()
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openSelectPhoto() {
        let vc = SelectPhotoAssembler.assembly(
            openGallerySubject: openGallerySubject,
            openCameraSubject: openCameraSubject)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in return 327 }]
            sheet.prefersGrabberVisible = false
        }
        vc.modalPresentationStyle = .pageSheet

        root?.present(vc, animated: true)
    }
    
    func showImagePicker(picker: UIImagePickerController) {
        root?.present(picker, animated: true)
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
    
}
