//
//  FileManagerService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift

final class FileManagerService {
    
    typealias CompletionHandler = (Bool) -> Void
    
    enum NameOfDirectory: String {
        case iconImage
    }
    
    init() {
        if !UDManagerService.get(.createImageDirectory) {
            createDirectory(name: .iconImage)
            UDManagerService.set(.createImageDirectory, value: true)
        }
    }
    
    func createDirectory(name directory: NameOfDirectory) {
        let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first!
        let url = documentURL.appendingPathComponent(directory.rawValue)
        
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    private func fileURL(for directory: NameOfDirectory, path: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userPhotosURL = documentURL.appendingPathComponent(directory.rawValue)
        return userPhotosURL.appendingPathComponent("\(path).jpg")
    }
    
    func save(directory: NameOfDirectory, image: UIImage,
              with path: String) -> Observable<UIImage>? {
        let userProfileURL = fileURL(for: directory, path: path)
        let userPhotosURL = userProfileURL.deletingLastPathComponent()

        // Ensure directory exists (defensive; init already creates it)
        if !FileManager.default.fileExists(atPath: userPhotosURL.path) {
            do {
                try FileManager.default.createDirectory(at: userPhotosURL, withIntermediateDirectories: true)
            } catch {
                print(#function, "Error creating directory: \(error)")
                return nil
            }
        }

        // Write off the main thread and emit one image on success, then complete.
        return Observable<UIImage>.create { observer in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = image.jpegData(compressionQuality: 1.0) else {
                    print(#function, "Failed to create JPEG data")
                    observer.onCompleted()
                    return
                }
                do {
                    try data.write(to: userProfileURL, options: .atomic)
                    print(#function, "Successfully wrote to file at: \(userProfileURL.path)")
                    observer.onNext(image)
                    observer.onCompleted()
                } catch {
                    print(#function, "Error writing to file: \(error)")
                    observer.onCompleted() // mirror previous behavior: no onError
                }
            }
            return Disposables.create()
        }
    }
    
    func read(directory: NameOfDirectory, with path: String) -> Observable<UIImage>? {
        let userProfileURL = fileURL(for: directory, path: path)

        // Return nil (as before) if the file doesn't exist — preserves current callers that use optional chaining.
        guard FileManager.default.fileExists(atPath: userProfileURL.path) else {
            print(#function, "File does not exist at path:", userProfileURL.path)
            return nil
        }

        // Perform I/O off the main thread and emit a single image, then complete.
        return Observable<UIImage>.create { observer in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: userProfileURL)
                    if let image = UIImage(data: data) {
                        observer.onNext(image)
                    } else {
                        print(#function, "Failed to decode image at path: \(userProfileURL.path)")
                    }
                    observer.onCompleted()
                } catch {
                    print(#function, "Error reading file: \(error)")
                    observer.onCompleted() // Don't error the chain; mirror previous behavior
                }
            }
            return Disposables.create()
        }
    }
    
    func delete(directory: NameOfDirectory, with path: String, completion: CompletionHandler?) {
        let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first!
        let userPhotosURL = documentURL.appendingPathComponent(directory.rawValue)
        
        let fileURL = userPhotosURL.appendingPathComponent("\(path).jpg")
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                completion?(true)
                print(#function, "File successfully deleted!")
            } else {
                completion?(false)
                print(#function, "File does not exist at path.")
            }
        } catch {
            completion?(false)
            print(#function, "Error deleting file: \(error)")
        }
    }
    
}
