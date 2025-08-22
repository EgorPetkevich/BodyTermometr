//
//  FileManagerService+Main.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 22.08.25.
//

import UIKit
import RxSwift

struct MainFileManagerServiceUseCase:
    MainFileManagerServiceUseCaseProtocol {
    
    private var fileManager: FileManagerService
    
    init(fileManager: FileManagerService) {
        self.fileManager = fileManager
    }
    
    func getIconImage() -> Observable<UIImage>? {
        fileManager.read(directory: .iconImage,
                         with: UserIconPath.path.rawValue)
    }
    
}

