//
//  CustomCellTableViewCell.swift
//  ProfileFirebaseDemo
//
//  Created by Ashish Kakkad on 03/06/19.
//  Copyright © 2019 hemangi. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var DOBlabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
