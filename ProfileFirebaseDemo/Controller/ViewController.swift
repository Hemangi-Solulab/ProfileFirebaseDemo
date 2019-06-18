//
//  ViewController.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 03/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


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
        let imgUrl = URL(string : profileArray[indexPath.row].photoURL)
            cell.imgProfilePic.kf.setImage(with: imgUrl)
        
        /* get image from url
         *************************************************************
        let url = URL(string: imgUrl)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.imgProfilePic.image = UIImage(data: data!)
            }
        }
         *************************************************************
  */
     
        
        return cell
    }
    
    
    
    //MARK: retrive data
    func retrieveData(){
        let profileDB = Database.database().reference().child("Profiles")
        
        profileDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let name = snapshotValue["name"]!
            let dob = snapshotValue["dob"]!
            let photoUrl = snapshotValue["photoURL"]!
            
        
        
            
            let profile = Profile()
            profile.name = name
            profile.dob = dob
            profile.photoURL = photoUrl
       
            self.profileArray.append(profile)
            self.ProfileTableView.reloadData()
    }
    
}

}
