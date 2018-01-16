//
//  TrackTableViewController.swift
//  AudioAnchor
//
//  Created by Joseph Ugowe on 1/5/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var albumPlaylist: [Album] = []
    var trackPlaylist: [Song] = []
    let apiClient = APIClient()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var currentIndex: Int = Int()
    var currentTrack: Song?
    @IBOutlet weak var tableView: UITableView!
    //var currentPlayerStatus: PlayerStatus = .waitingToPlay
    //@IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioPlayer.sharedInstance.isPaused = true
    }
    
    override func viewDidLoad() {
    super.viewDidLoad()
       //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchcell")
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        apiClient.fetchAudioTracks { (results, errorMessage) in
            if let results = results{
                self.albumPlaylist = results
                self.trackPlaylist = results[0].songs
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumPlaylist.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath) as! SearchTableViewCell
     
        let album = albumPlaylist[indexPath.row]
        cell.albumTitle.text = album.title
        
        album.downloadImage(url: album.imageURL) { (songImage) in
            DispatchQueue.main.async {
                if songImage != nil {
                    cell.albumImage.image = songImage
                }
            }
        }
 
    /*
        if currentIndex == indexPath.row {
            cell.backgroundColor = .orange
            cell.togglePlayPause()
            cell.playOrPauseImage.isHidden = false
        } else {
            cell.backgroundColor = .white
            cell.togglePlayPause()
            cell.playOrPauseImage.isHidden = true
        }
 */
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        performSegue(withIdentifier: "ShowNext", sender: self)
    }
 
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "SearchViewController", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerController
        navigationController?.pushViewController(destination, animated: true)
    }
 */
    
    
}




