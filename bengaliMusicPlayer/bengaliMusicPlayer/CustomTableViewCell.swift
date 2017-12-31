//
//  CustomTableViewCell.swift
//  bengaliMusicPlayer
//
//  Created by Dipankar Dutta on 12/31/17.
//  Copyright © 2017 Dipankar Dutta. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var btnDownload: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
