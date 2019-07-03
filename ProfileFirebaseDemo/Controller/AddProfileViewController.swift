//
//  AddProfileViewController.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 03/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit
import Firebase

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var PhotoImgView: UIImageView!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var DOBtextField: UITextField!
    
    private var DOBdatePicker = UIDatePicker()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DOBdatePicker.datePickerMode = .date
        DOBdatePicker.addTarget(self, action: #selector(AddProfileViewController.dateChanged(DOBdatePicker:)), for: .valueChanged)
        DOBtextField.inputView = DOBdatePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDatePicker(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dateChanged(DOBdatePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        DOBdatePicker.maximumDate = Date()
        DOBtextField.text = dateFormatter.string(from: DOBdatePicker.date)
    }
    
    @objc func closeDatePicker(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func SaveBtnClicked(_ sender: Any) {
        uploadPhoto(self.PhotoImgView.image!){ url in
            self.saveData(picURL: url!){ success in
                if success != nil {
                    print("Yeah..")
                }
            }
        }
        
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard (info[.editedImage] as? UIImage) != nil else {
            print("No image found")
            return
        }
        
        picker.dismiss(animated: true) {
            self.PhotoImgView.image = info[.editedImage] as? UIImage
        }
    }
    
    @IBAction func btnTakePicturre(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let cameraButton = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(.camera){
                let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
                })
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true)
            }
        })
        
        let galleryButton = UIAlertAction(title: "Gallery", style: .default) { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.delegate = self
            self.present(self.imagePicker,animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(cameraButton)
        optionMenu.addAction(galleryButton)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func uploadPhoto(_ image:UIImage, completion : @escaping((_ url:URL?) -> ())){
        let imgName = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(imgName).png")
        let imgData = PhotoImgView.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            
            if error == nil{
                print("Success")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            }else {
                print(error!)
                completion(nil)
            }
        }
    }
    
    func saveData(picURL : URL, completion : @escaping((_ url:URL?) -> ())){
        
        let profileDictionary = ["name" : NameTextField.text!, "dob" : DOBtextField.text!, "photoURL" : picURL.absoluteString] as [String : Any]
        let profileDB = Database.database().reference().child("Profiles")
        
        profileDB.childByAutoId().setValue(profileDictionary){
            (error, reference) in
            if error != nil {
                print(error!)
            }else {
                print("Message saved successfully..")
                self.NameTextField.text = ""
                self.DOBtextField.text = ""
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
