//
//  ItemTableViewCell.swift
//  SearchingSorting
//
//  Created by ebsadmin on 28/06/21.
//  Copyright © 2021 droisys. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var aboutMe: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoView.layer.cornerRadius = photoView.frame.height/2 // For round imageView
        photoView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
