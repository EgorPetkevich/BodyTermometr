//
//  ProfileVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import Foundation
import RxSwift
import RxCocoa
import Photos
import UIKit
import AVFoundation

protocol ProfileRouterProtocol {
    var openGallerySubject: PublishSubject<Void> { get set }
    var openCameraSubject: PublishSubject<Void> { get set }
    func showImagePicker(picker: UIImagePickerController)
    func openSelectPhoto()
    func dismiss()
}

protocol ProfileRealmDataManagerUseCaseProtocol {
    var userInfo: Observable<UserInfoDTO> { get }
    func saveUserInfo(name: String, age: String, gender: Gender)
}

protocol ProfileKeyBoardHelperServiceUseCaseProtocol {
    var frame: Observable<CGRect> { get }
}

protocol ProfileFileManagerServiceUseCaseProtocol {
    func save(icon: UIImage) -> Observable<UIImage>?
    func getIconImage() -> Observable<UIImage>?
}

final class ProfileVM: NSObject, ProfileViewModelProtocol {
    
    //Out
    @Subject(value: UserInfoDTO(UserInfoModel()))
    var userInfoDTO: Observable<UserInfoDTO>
    @Subject()
    var keyBoardFrame: Observable<CGRect>
    @Subject()
    var iconImage: Observable<UIImage>
    @Subject()
    var openGallerySubject: Observable<Void>
    @Subject()
    var openCameraSubject: Observable<Void>
    
    //In
    var backButtonTapped: PublishSubject<Void> = .init()
    var saveButtonTapped: PublishSubject<Void> = .init()
    var choosePhotoButtonTapped: PublishSubject<Void> = .init()
    var userNameSubject: BehaviorSubject<String?> = .init(value: "")
    var userAgeSubject: BehaviorSubject<String?> = .init(value: "")
    var userGenderSubject: BehaviorSubject<Gender> = .init(value: .female)
    
    private var router: ProfileRouterProtocol
    private var realmDataManager: ProfileRealmDataManagerUseCaseProtocol
    private var keyboardHelper: ProfileKeyBoardHelperServiceUseCaseProtocol
    private var fileManageService: ProfileFileManagerServiceUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: ProfileRouterProtocol,
         realmDataManager: ProfileRealmDataManagerUseCaseProtocol,
         keyboardHelper: ProfileKeyBoardHelperServiceUseCaseProtocol,
         fileManageService: ProfileFileManagerServiceUseCaseProtocol
    ) {
        self.router = router
        self.realmDataManager = realmDataManager
        self.keyboardHelper = keyboardHelper
        self.fileManageService = fileManageService
        super.init()
        bind()
    }
    
    func viewDidLoad() {
        
    }
    
    private func bind() {
        bindRouterRelays()
        bindServicesOutputs()
        bindActions()
        bindOpeners()
        bindSaveFlow()
    }
    
    // MARK: - Binding helpers
    private func bindRouterRelays() {
        router.openGallerySubject
            .bind(to: _openGallerySubject.rx)
            .disposed(by: bag)
        router.openCameraSubject
            .bind(to: _openCameraSubject.rx)
            .disposed(by: bag)
    }

    private func bindServicesOutputs() {
        fileManageService
            .getIconImage()?
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] img in
                self?._iconImage.rx.onNext(img)
            })
            .disposed(by: bag)

        realmDataManager
            .userInfo
            .do(onNext: { [weak self] dto in
                // propagate DTO values into input subjects so validation sees them as filled
                self?.userNameSubject.onNext(dto.userName)
                self?.userAgeSubject.onNext(dto.userAge)
                if let gender = dto.gender { self?.userGenderSubject.onNext(gender) }
            })
            .bind(to: _userInfoDTO.rx)
            .disposed(by: bag)

        keyboardHelper
            .frame
            .bind(to: _keyBoardFrame.rx)
            .disposed(by: bag)
    }

    private func bindActions() {
        backButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.router.dismiss()
            })
            .disposed(by: bag)

        choosePhotoButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.router.openSelectPhoto()
            })
            .disposed(by: bag)
    }

    private func bindOpeners() {
        openGallerySubject
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.openGallery()
            })
            .disposed(by: bag)

        openCameraSubject
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.openCamera()
            })
            .disposed(by: bag)
    }

    private func bindSaveFlow() {
        // Streams from inputs
        let nameInput = userNameSubject
            .map { ($0 ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let ageInput = userAgeSubject
            .map { ($0 ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let genderInput = userGenderSubject.asObservable()

        // Current DTO stream
        let dtoStream = userInfoDTO

        saveButtonTapped
            .withLatestFrom(
                Observable.combineLatest(nameInput,
                                         ageInput,
                                         genderInput,
                                         dtoStream))
        
            .map { name, age, gender, dto -> (String, String, Gender) in
               
                let effectiveName = name.isEmpty ? dto.userName
                    .trimmingCharacters(in: .whitespacesAndNewlines) : name
                let effectiveAge  = age.isEmpty  ? dto.userAge
                    .trimmingCharacters(in: .whitespacesAndNewlines)  : age
                return (effectiveName, effectiveAge, gender)
            }
            .filter { name, age, _ in !name.isEmpty && !age.isEmpty }
            .withUnretained(self)
            .do(onNext: { owner, tuple in
                let (name, age, gender) = tuple
                owner.realmDataManager.saveUserInfo(name: name,
                                                    age: age,
                                                    gender: gender)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.dismiss()
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Gallery Setup
extension ProfileVM: UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate,
                          UIAdaptivePresentationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true) { [weak self] in
            if
                let self,
                let image = info[.originalImage] as? UIImage
            {
                
//                self._iconImage.rx.onNext(image)
                self.fileManageService.save(icon: image)?
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] img in
                        self?._iconImage.rx.onNext(img) // only onNext; avoid completing the Subject
                    })
                    .disposed(by: self.bag)
                
                // Navigate to editor with the originally selected image
//                self.router.openEditor(with: image)
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func openGallery() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized, .limited:
                    self?.createAndShowImagePicker()
                case .denied, .restricted:
                    self?.showGalleryErrorAlert()
                default:
                    break
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.createAndShowImagePicker()
                case .denied, .restricted:
                    self?.showGalleryErrorAlert()
                default:
                    break
                }
            }
        }
    }
    
    private func createAndShowImagePicker() {
        DispatchQueue.main.async { [weak self] in
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            imagePickerVC.presentationController?.delegate = self
            self?.router.showImagePicker(picker: imagePickerVC)
        }
        
    }
    
    private func showGalleryErrorAlert() {
//        DispatchQueue.main.async { [weak self] in
//            self?.alertService.showCameraError(goSettingsHandler: {
//                if let appSettings =
//                    URL(string: UIApplication.openSettingsURLString) {
//                           UIApplication.shared.open(appSettings,
//                                                     options: [:],
//                                                     completionHandler: nil)
//
//                }
//            })
            
//        }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // Fallback to gallery if no camera
            openGallery()
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            createAndShowCameraPicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.createAndShowCameraPicker()
                    } else {
                        self?.showGalleryErrorAlert()
                    }
                }
            }
        case .denied, .restricted:
            showGalleryErrorAlert()
        @unknown default:
            break
        }
    }

    private func createAndShowCameraPicker() {
        DispatchQueue.main.async { [weak self] in
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
            imagePickerVC.cameraCaptureMode = .photo
            imagePickerVC.delegate = self
            imagePickerVC.presentationController?.delegate = self
            self?.router.showImagePicker(picker: imagePickerVC)
        }
    }
}
