//
//  FileManagerService+Profile.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift

struct ProfileFileManagerServiceUseCase:
    ProfileFileManagerServiceUseCaseProtocol {
    
    private var fileManager: FileManagerService
    
    init(fileManager: FileManagerService) {
        self.fileManager = fileManager
    }
    
    func save(icon: UIImage) -> Observable<UIImage>? {
        fileManager.save(directory: .iconImage,
                         image: icon,
                         with: UserIconPath.path.rawValue)
    }
    
    func getIconImage() -> Observable<UIImage>? {
        fileManager.read(directory: .iconImage,
                         with: UserIconPath.path.rawValue)
    }
    
}
