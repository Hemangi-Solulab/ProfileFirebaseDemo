//
//  ViewController.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 03/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var profileArray : [Profile] = [Profile]()

    @IBOutlet weak var ProfileTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ProfileTableView.delegate = self
        ProfileTableView.dataSource = self
        
        
 
    ProfileTableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProfileCell")
    
        retrieveData()
    
    }
    //MARK: table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProfileCell", for: indexPath) as! CustomCellTableViewCell
 
        
            cell.NameLabel.text = profileArray[indexPath.row].name
            cell.DOBlabel.text = profileArray[indexPath.row].dob
      
        
        return cell
    }
    
    
    
    //MARK: retrive data
    func retrieveData(){
        let profileDB = Database.database().reference().child("Profiles")
        
        profileDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let name = snapshotValue["name"]!
            let dob = snapshotValue["dob"]!
            
            var profile = Profile()
            profile.name = name
            profile.dob = dob
            self.profileArray.append(profile)
            self.ProfileTableView.reloadData()
    }
    
}

}
