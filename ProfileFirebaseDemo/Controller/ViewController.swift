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
import GoogleMobileAds
//import MYTableViewIndex


@objc protocol CollationIndexable {
    @objc var collationString : String { get }
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    
    
    var profileArray : [Profile] = [Profile]()
    var profileToSend = Profile()
    var interstitial: GADInterstitial!
    let request = GADRequest()
    
    //try
//    var profileDictionary = [String: [Profile]]()
//    var profileSectionTitles = [String]()
    
    let collation = UILocalizedIndexedCollation.current()
    var sections: [[AnyObject]] = []
    var objects: [AnyObject] = [] {
        didSet {
            
            let selector = #selector(getter: CollationIndexable.collationString)
            sections = Array(repeating: [], count: collation.sectionTitles.count)

            let sortedObjects = collation.sortedArray(from: objects, collationStringSelector: selector)
            for object in sortedObjects {
                let sectionNumber = collation.section(for: object, collationStringSelector: selector)
                sections[sectionNumber].append(object as AnyObject)
            }
            
            self.ProfileTableView.reloadData()
        }
    }
    
    @IBOutlet weak var ProfileTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
   // @IBOutlet fileprivate var tableViewIndex: TableViewIndex!
    //    fileprivate var indexDataSource: TableViewIndexDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileTableView.delegate = self
        ProfileTableView.dataSource = self
        
        ProfileTableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProfileCell")
        
        retrieveData()
        
        //MARK: Ads
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.load(request)
        
        GADRewardBasedVideoAd.sharedInstance().delegate = self
       
        
 //let tableViewIndexController = TableViewIndexController(scrollView: ProfileTableView)
       
//tableViewIndexController.tableViewIndex.dataSource = indexDataSource
        
      //  indexDataSource = ["A","B"] as! TableViewIndexDataSource
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collation.sectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return collation.section(forSectionIndexTitle: index)
    }
    
    @IBAction func createAdvPressed(_ sender: Any) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            interstitial = reloadInterstitialAd()
        }else {
            print("Adv Not ready")
        }
    }
    
    func reloadInterstitialAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.load(request)
        return interstitial
    }
    
    
    @IBAction func playVideoAdvPressed(_ sender: Any) {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
    }
    
    //MARK: table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
//        let profileKey = profileSectionTitles[section]
//        if let profileValues = profileDictionary[profileKey] {
//            return profileValues.count
//        }
//
//        return 0
        //if sections[section].count > 0 {
            return sections[section].count
        //} else{
//            return 0
//        }
        
//        return collation.sectionIndexTitles.count

       // return profileArray.count
    }
    
   func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        //return profileSectionTitles.count
    //return collation.sectionTitles.count
    return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProfileCell", for: indexPath) as! CustomCellTableViewCell
      
        
//        let profileKey = profileSectionTitles[indexPath.section]
//        if let profileValues = profileDictionary[profileKey] {
//
        
        cell.NameLabel.text = profileArray[indexPath.row].name
        cell.DOBlabel.text = profileArray[indexPath.row].dob
        let imgUrl = URL(string : profileArray[indexPath.row].photoURL)
        cell.imgProfilePic.kf.setImage(with: imgUrl)
        
        
//        }
        
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
    
//  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return profileSectionTitles[section]
//    }
//
//   func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return profileSectionTitles
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentProfile = profileArray[indexPath.row]
        performSegue(withIdentifier: "goToDetail", sender: currentProfile)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destVC = segue.destination as! ProfileDetailViewController
            destVC.currentProfile = sender as? Profile
        }
    }
    
    //MARK: retrive data
    func retrieveData(){
        let profileDB = Database.database().reference().child("Profiles")
        profileDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let profile = Profile()
            profile.name = snapshotValue["name"]!
            profile.dob = snapshotValue["dob"]!
            profile.photoURL = snapshotValue["photoURL"]!
            
            self.profileArray.append(profile)
            self.objects.append(profile)
            
            
            //MARK: alphabetical scrollbar
//            for profile1 in self.profileArray {
//                let profileKey = String(profile1.name.prefix(1))
//                if var profileValues = self.profileDictionary[profileKey] {
//                    profileValues.append(profile1)
//                    self.profileDictionary[profileKey] = profileValues
//                } else {
//                    self.profileDictionary[profileKey] = [profile1]
//                }
//            }
//            
//            // 2
//            self.profileSectionTitles = [String](self.profileDictionary.keys)
//            self.profileSectionTitles = self.profileSectionTitles.sorted(by: { $0 < $1 })
//            
//            
            
            
            
            
            self.ProfileTableView.reloadData()
        }
    }
}

extension ViewController : GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
}

//extension ViewController : TableViewIndexDelegate, TableViewIndexDataSource {
//    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
//        return UILocalizedIndexedCollation.current().sectionIndexTitles.map{ title -> UIView in
//            return StringItem(text: title)
//        }
//    }
//
//    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
//        let indexPath = NSIndexPath(forRow: 0, inSection: sectionIndex)
//        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
//
//        return true // return true to produce haptic feedback on capable devices
//    }

//}
