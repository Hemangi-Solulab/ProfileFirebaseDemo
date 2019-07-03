//
//  ProfileDetailViewController.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 18/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit
import CoreImage
import Kingfisher
import Firebase

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var profileCirclePic: UIImageView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var dobTextView: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var changeImgButton: UIButton!
    
    
    
    
    var currentProfile : Profile!
     var imagePicker: UIImagePickerController = UIImagePickerController()
    private var DOBdatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        
        //        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        //        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.frame = bigImageView.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        bigImageView.addSubview(blurEffectView)
    }
    override func viewDidLayoutSubviews() {
        makeRound(view: profileCirclePic)
        bigImageView.addBottomRoundedEdge(desiredCurve: 1.5)
        
        
        
        let url = URL(string : currentProfile.photoURL)
        profileCirclePic.kf.setImage(with: url)
        bigImageView.kf.setImage(with: url)
        nameTextView.text = currentProfile.name
        nameTextView.isEnabled = false
        dobTextView.text = currentProfile.dob
        
        
        blurEffect()
        
        DOBdatePicker.datePickerMode = .date
        DOBdatePicker.addTarget(self, action: #selector(ProfileDetailViewController.dateChanged(DOBdatePicker:)), for: .valueChanged)
        dobTextView.inputView = DOBdatePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDatePicker(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dateChanged(DOBdatePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        DOBdatePicker.maximumDate = Date()
        dobTextView.text = dateFormatter.string(from: DOBdatePicker.date)
    }
    
    @objc func closeDatePicker(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func makeRound(view : UIView){
        view.layer.cornerRadius = view.frame.size.height / 2
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = false
        view.clipsToBounds = true
    }
    
    @IBAction func changeImgButtonPreesed(_ sender: Any) {
        
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
    
    @IBAction func editButttonClicked(_ sender: UIButton) {
        if sender.currentTitle == "EDIT" {
            nameTextView.isEnabled = true
            nameTextView.becomeFirstResponder()
            sender.setTitle("SAVE", for: .normal)
        }else {
            sender.setTitle("EDIT", for: .normal)
            nameTextView.isEnabled = false
            nameTextView.resignFirstResponder()
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
//        uploadPhoto(self.profileCirclePic.image!){ url in
//            self.saveData(picURL: url!){ success in
//                if success != nil {
//                    print("Yeah..")
//                }
//            }
//        }
    }
    
    func uploadPhoto(_ image:UIImage, completion : @escaping((_ url:URL?) -> ())){
        let imgName = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(imgName).png")
        let imgData = profileCirclePic.image?.pngData()
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

//    func saveData(picURL : URL, completion : @escaping((_ url:URL?) -> ())){
//
//        let profileDictionary = ["name" : nameTextView.text!, "dob" : dobTextView.text!, "photoURL" : picURL.absoluteString] as [String : Any]
//        let profileDB = Database.database().reference().child("Profiles")
//
//        profileDB.childByAutoId().setValue(profileDictionary){
//            (error, reference) in
//            if error != nil {
//                print(error!)
//            }else {
//                print("Message saved successfully..")
//                self.NameTextField.text = ""
//                self.DOBtextField.text = ""
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//        }
//    }
//
    
    func blurEffect() {
        //let thumb1 = bigImageView.image!.resized(withPercentage: 0.05)
        
        let thumb2 = bigImageView.image!.resized(toWidth: 100.0)
        bigImageView.image = thumb2
        
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: bigImageView.image!)
        
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(2, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        bigImageView.image = processedImage
    }
}

extension UIView {
    
    func addBottomRoundedEdge(desiredCurve: CGFloat?) {
        let offset: CGFloat = self.frame.width / desiredCurve!
        let bounds: CGRect = self.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension ProfileDetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard (info[.editedImage] as? UIImage) != nil else {
            print("No image found")
            return
        }
        
        picker.dismiss(animated: true) {
            self.profileCirclePic.image = info[.editedImage] as? UIImage
            self.bigImageView.image = info[.editedImage] as? UIImage
            self.blurEffect()
        }
    }
}

