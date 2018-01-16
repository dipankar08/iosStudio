//
//  SongTableViewCell.swift
//  AudioAnchor
//
//  Created by Dipankar Dutta on 1/14/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sl: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var PlayOrPauseImage: UIImageView!
    @IBOutlet weak var author: UILabel!
    
    let playImage = UIImage(named:"play")

  
    let pauseImage = UIImage(named:"pause")
    
    func togglePlayPause() {
        if AudioPlayer.sharedInstance.isPaused {
            PlayOrPauseImage.image = playImage
        } else {
            PlayOrPauseImage.image = pauseImage
        }
    }
    
    func getDataFromURL(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    

}
