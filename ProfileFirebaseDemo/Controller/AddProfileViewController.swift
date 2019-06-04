//
//  AddProfileViewController.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 03/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit
import Firebase

class AddProfileViewController: UIViewController {
    
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var DOBtextField: UITextField!
    
    private var DOBdatePicker : UIDatePicker?
    
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
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        DOBtextField.text = dateFormatter.string(from: DOBdatePicker.date)
        
    
    }
    @objc func closeDatePicker(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func SaveBtnClicked(_ sender: Any) {
        
        
        let profileDB = Database.database().reference().child("Profiles")
        
        let profileDictionary = ["name" : NameTextField.text!, "dob" : DOBtextField.text!]
        
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
