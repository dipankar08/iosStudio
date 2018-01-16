//
//  Track.swift
//  AudioAnchor
//
//  Created by Joseph Ugowe on 1/5/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import Foundation
import UIKit

class Song{
    let title:String
    let author:String
    let mediaURL:URL
    var downloaded = false
    init(title: String, author:String, mediaURL: URL) {
        self.title = title
        self.mediaURL = mediaURL
        self.author = author
    }
    
    func downloadImage(url: URL,_ completionHandler: @escaping (_ image: UIImage?) -> () ){
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let imageData = data else { print("Problem parsing imageData"); return}
                
                if let image = UIImage(data: imageData){
                    completionHandler(image)
                }
            }
            }.resume()
    }
}

class Album{
    let title:String
    let imageURL:URL
    let songs :[Song]
    init(title: String, imageURL:URL, songs: [Song]) {
        self.title = title
        self.imageURL = imageURL
        self.songs = songs
    }
    
    func downloadImage(url: URL,_ completionHandler: @escaping (_ image: UIImage?) -> () ){
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let imageData = data else { print("Problem parsing imageData"); return}
                
                if let image = UIImage(data: imageData){
                    completionHandler(image)
                }
            }
            }.resume()
    }
}

extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return
            lhs.title == rhs.title &&
                lhs.mediaURL == rhs.mediaURL
    }
}
