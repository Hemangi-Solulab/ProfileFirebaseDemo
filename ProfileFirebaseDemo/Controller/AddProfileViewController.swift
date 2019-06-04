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
    
    @IBOutlet weak var DOBPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func DOBDatePicker(_ sender: Any) {
        
        
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
                self.DOBPicker.date = Date.init()
               self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    
    }
    
    
    
}
