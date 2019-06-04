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
    
    var profileArray : Dictionary<String , String> = ["name":"a", "dob" : "10-08-1992"]

    @IBOutlet weak var ProfileTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ProfileTableView.delegate = self
        ProfileTableView.dataSource = self
        
        
 
    ProfileTableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProfileCell")
    
    
    }
    //MARK: table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProfileCell", for: indexPath) as! CustomCellTableViewCell
        //var items = profileArray.values as! Dictionary<String , String>
        cell.NameLabel.text = profileArray["name"] as! String
        cell.DOBlabel.text = profileArray["dob"] as! String
       
        return cell
    }
    
    
    
    //MARK: retrive data
    
//    let messageDB = Database.database().reference().child("Messages")
//
//    messageDB.observe(.childAdded) { (snapshot) in
//
//    let snapshotValue = snapshot.value as! Dictionary<String,String>
//    let text = snapshotValue["MessageBody"]!
//    let sender = snapshotValue["Sender"]!
//
//
//    var msg = Message()
//    msg.messageBody = text
//    msg.sender = sender
//    self.messageArray.append(msg)
    
    
}

