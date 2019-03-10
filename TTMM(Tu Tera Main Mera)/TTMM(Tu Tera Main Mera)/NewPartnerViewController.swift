//
//  NewTravelPartnerViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/27/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class NewPartnerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var txtPartnerName: UITextField!
    @IBOutlet var addPhotoUIButton: UIButton!
    @IBOutlet var saveBtn: UIBarButtonItem!
    @IBOutlet var partnerImg: UIImageView!
    var pickedImageData: Data!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPartnerName.keyboardType = UIKeyboardType.alphabet
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if partnerImg.image == nil || txtPartnerName.text == nil {
//            saveBtn.isEnabled = false
//        } else {
//            saveBtn.isEnabled = true
//        }
        
        
        self.partnerImg.layer.cornerRadius = 150.0
        self.addPhotoUIButton.layer.cornerRadius = 27.0
        self.partnerImg.layer.borderWidth = 1.0
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let pickedImg = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        pickedImageData = pickedImg.jpegData(compressionQuality: 0.2)
        partnerImg.image = pickedImg
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// Mark:- IBActions

extension NewPartnerViewController {
    
    @IBAction func addPartnerPhoto() {
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        let alertActionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imgPicker.sourceType = .camera
                self.present(imgPicker, animated: true, completion: nil)
            }else {
                print("Camera is not available right now")
            }
            
        }
        
        let actionPhotoLib = UIAlertAction(title: "Photos", style: .default) { (action: UIAlertAction) in
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated: true, completion: nil)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alertActionSheet.addAction(actionCamera)
        alertActionSheet.addAction(actionPhotoLib)
        alertActionSheet.addAction(actionCancel)
        
        self.present(alertActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func addEventPartner() {
        if partnerImg.image == nil || txtPartnerName.text == nil {
            let alert = UIAlertController(title: "error: Empty Field(s)", message: "Make sure to fill the field(s).", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Retry", style: .cancel, handler: nil)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(alertAction)
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let addPartner = Partner(context: context)
            
            let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let imageSavePath = directoryPath! + "\(txtPartnerName.text!).jpg"
            let fileManager = FileManager.default
            let isSuccessfulWrite = fileManager.createFile(atPath: imageSavePath, contents: pickedImageData, attributes: nil)
            
            if isSuccessfulWrite == true {
                addPartner.photo = imageSavePath
                addPartner.partnerName = txtPartnerName.text!
            }
            else {
                print("******** SOME ERROR")
            }
            
            addPartner.partnerName = txtPartnerName.text
            
            do {
                try context.save()
                let alert = UIAlertController(title: "Partner Added", message: nil, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true, completion: nil)
                alert.addAction(alertAction)
                
                txtPartnerName.text = nil
                partnerImg.image = nil
            } catch {
                print(error.localizedDescription)
            }
        }
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
