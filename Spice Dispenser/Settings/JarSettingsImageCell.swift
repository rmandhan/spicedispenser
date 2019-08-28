//
//  JarSettingsImageCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-19.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit
import AVFoundation

class JarSettingsImageCell: UITableViewCell, UINavigationControllerDelegate {

    @IBOutlet weak var spiceImageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    
    var jarNum: Int!
    var imageName: String!
    var originalImageName: String!
    var delegate: JarSettingsDelegate!
    var imagePickerController : UIImagePickerController!
    var capturedImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setProperties(jarNum: Int, imageName: String, originalImageName: String) {
        self.jarNum = jarNum
        self.imageName = imageName
        self.originalImageName = originalImageName
    }
    
    func notifyDelegate() {
        delegate.spiceImageDidUpdateWithName(name: imageName)
    }
    
    func showPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        delegate.presentUIViewController(controller: self.imagePickerController)
    }
    
    func showCamera() {
        imagePickerController.sourceType = .camera
        imagePickerController.cameraCaptureMode = .photo
        delegate.presentUIViewController(controller: self.imagePickerController)
    }
    
    func resetPhoto() {
        imageName = self.originalImageName
        loadImage()
        notifyDelegate()
    }
    
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "Camera Access Required", message: "Please grant permission to use the Camera to be able to take pictures", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettingsURL) {
                    UIApplication.shared.open(appSettingsURL, completionHandler: nil)
                }
            }
        })
        delegate.presentUIViewController(controller: alert)
    }
    
    func loadImage() {
        if imageName == "default" {
            spiceImageView.image = UIImage(named: "Default Spices")
        } else {
            let fileManager = FileManager.default
            let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(self.imageName)
            if fileManager.fileExists(atPath: imagePath){
                spiceImageView.image = UIImage(contentsOfFile: imagePath)
            } else{
                print("No image found for path: \(imagePath)")
            }
        }
    }
    
    func saveImageWithName(name: String) {
        guard let image = self.capturedImage else { return }
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        let data = image.pngData()
        if (fileManager.createFile(atPath: imagePath, contents: data, attributes: nil)) {
            imageName = name
            notifyDelegate()
        } else {
            print("Failed to save image")
        }
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        let photoActionSheet = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.showPhotoLibrary()
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
                case .denied:
                    self.alertPromptToAllowCameraAccessViaSettings()
                default:
                    self.showCamera()
            }
        })
        
        let resetPhotoAction = UIAlertAction(title: "Reset Photo", style: .default, handler: { (action) in
            self.resetPhoto()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoActionSheet.addAction(photoLibraryAction)
        photoActionSheet.addAction(takePhotoAction)
        photoActionSheet.addAction(resetPhotoAction)
        photoActionSheet.addAction(cancelAction)
        
        delegate.presentUIViewController(controller: photoActionSheet)
    }
}

extension JarSettingsImageCell: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        imagePickerController.dismiss(animated: true, completion: nil)
        capturedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        spiceImageView.image = capturedImage
        saveImageWithName(name: String.init(format: "temp%d", jarNum))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
