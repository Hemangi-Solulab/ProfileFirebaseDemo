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
    
    private var DOBdatePicker : UIDatePicker?
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DOBdatePicker = UIDatePicker()
        DOBdatePicker?.datePickerMode = .date
        DOBdatePicker?.addTarget(self, action: #selector(AddProfileViewController.dateChanged(DOBdatePicker:)), for: .valueChanged)
        
        
        
        DOBtextField.inputView = DOBdatePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDatePicker(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        
        // Do any additional setup after loading the view.
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
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        PhotoImgView.image = info[.originalImage] as? UIImage
        
       
        
    }
    
    
    @IBAction func btnTakePicturre(_ sender: Any) {
        let vc = UIImagePickerController()
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            
//            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
//
//            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
//            })
//
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion:nil)
            
        }
        else{
            //other action
           vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            present(vc, animated: true)
        }

        
        
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
                print(error)
                completion(nil)
                
            }
            
        }
        
    }
    
    func saveData(picURL : URL, completion : @escaping((_ url:URL?) -> ())){
       
        let profileDictionary = ["name" : NameTextField.text!, "dob" : DOBtextField.text!, "photoURL" : picURL.absoluteString] as! [String : Any]
        
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
