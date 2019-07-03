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

class ViewController: UIViewController {
    
    @IBOutlet weak var ProfileTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var profileArray : [Profile] = [Profile]()
    var profileToSend = Profile()
    var interstitial: GADInterstitial!
    let request = GADRequest()
    
    //MARK: try index on tableView
    
    // let profileIndexTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var profileSection = [String]()
    var profileDictionary = [String: [Profile]]()
    func generateProfileDict(){
        profileSection.removeAll()
        profileDictionary.removeAll()
        
        for profile in profileArray{
            
            let key = "\(profile.name[profile.name.startIndex])"
            let upper = key.uppercased()
            
            if var profileValues = profileDictionary[upper] {
                profileValues.append(profile)
                profileDictionary[upper] = profileValues
            } else {
                profileDictionary[upper] = [profile]
            }
        }
        profileSection = [String](profileDictionary.keys)
        profileSection = profileSection.sorted()
        
        self.ProfileTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileTableView.delegate = self
        ProfileTableView.dataSource = self
        
        ProfileTableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProfileCell")
        
        retrieveData {
            print("DONE")
        }
        
        //MARK: Google AdMob
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.load(request)
        
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    //MARK: retrive data
    func retrieveData(finished: () -> Void){
        
        let profileDB = Database.database().reference().child("Profiles")
        profileDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let profile = Profile()
            profile.name = snapshotValue["name"]!
            profile.dob = snapshotValue["dob"]!
            profile.photoURL = snapshotValue["photoURL"]!
            
            self.profileArray.append(profile)
            self.generateProfileDict()
            //self.ProfileTableView.reloadData()
        }
        print(profileArray.count)
        finished()
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
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destVC = segue.destination as! ProfileDetailViewController
            destVC.currentProfile = sender as? Profile
        }
    }
    
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let profileKey = profileSection[section]
        if let profileValues = profileDictionary[profileKey] {
            return profileValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProfileCell", for: indexPath) as! CustomCellTableViewCell
        
        let profileKey = profileSection[indexPath.section]
        if let profileValues = profileDictionary[profileKey.uppercased()]{
            cell.NameLabel.text = profileValues[indexPath.row].name
            cell.DOBlabel.text = profileValues[indexPath.row].dob
            let imgUrl = URL(string : profileValues[indexPath.row].photoURL)
            cell.imgProfilePic.kf.setImage(with: imgUrl)
        }
        return cell
    }
    
    //MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileKey = profileSection[indexPath.section]
        let currentProfile = profileDictionary[profileKey.uppercased()]![indexPath.row]
        
        performSegue(withIdentifier: "goToDetail", sender: currentProfile)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Table View Index and Section Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return profileSection[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return profileSection
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let index = profileSection.firstIndex(of: title) else { return -1 }
        return index
    }
}

extension ViewController : GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
}

