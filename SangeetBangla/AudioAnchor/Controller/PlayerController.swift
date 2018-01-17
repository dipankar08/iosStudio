//
//  PlayerController.swift
//  AudioAnchor
//
//  Created by Dipankar Dutta on 1/14/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

private let reuseIdentifier = "Cell"

class PlayerController:  UIViewController, UITableViewDataSource, UITableViewDelegate{

    var album: Album?
    let apiClient = APIClient()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var currentIndex: Int = Int()
    var currentTrack: Song?
    var currentPlayerStatus: PlayerStatus = .waitingToPlay
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headimage: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioPlayer.sharedInstance.isPaused = true
        self.setupTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self;
        tableView.delegate = self;
        
        album?.downloadImage(url: (album?.imageURL)!) { (songImage) in
            DispatchQueue.main.async {
                if songImage != nil {
                    self.headimage.image = songImage
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (album?.songs.count)!
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "songcell") as! SongTableViewCell


        let track = album?.songs[indexPath.row]
        cell.sl.text = String(indexPath.row)
        //cell.author.text = track?.author
        cell.author.isHidden = true
        cell.title.text = track?.title

        if currentIndex == indexPath.row {
            cell.title.textColor = .black
            cell.togglePlayPause()
            cell.PlayOrPauseImage.isHidden = false
        } else {
            cell.title.textColor = .gray
            cell.togglePlayPause()
            cell.PlayOrPauseImage.isHidden = true
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let track = album?.songs[indexPath.row]
        currentIndex = indexPath.row
        
        if currentTrack == track {
            if currentPlayerStatus == .paused {
                AudioPlayer.sharedInstance.avPlayer.play()
                AudioPlayer.sharedInstance.isPaused = false
                currentPlayerStatus = .playing
                print(currentPlayerStatus)
            } else if currentPlayerStatus == .playing {
                AudioPlayer.sharedInstance.avPlayer.pause()
                AudioPlayer.sharedInstance.isPaused = true
                currentPlayerStatus = .paused
                print(currentPlayerStatus)
            }
        } else {
            AudioPlayer.sharedInstance.play(url: (track?.mediaURL)!)
            AudioPlayer.sharedInstance.isPaused = false
            currentPlayerStatus = .playing
        }
        
        currentTrack = track
        //tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func didPlayToEnd() {
        self.playNextTrack(trackPlaylist: (album?.songs)!, currentIndex: &currentIndex)
        self.tableView.reloadData()
        print("This beautiful song has ended")
    }
    
    func playNextTrack(trackPlaylist: [Song], currentIndex: inout Int) {
        if (currentIndex < trackPlaylist.count - 1) {
            currentIndex += 1
            AudioPlayer.sharedInstance.isPaused = false
            let nextTrack = trackPlaylist[currentIndex]
            AudioPlayer.sharedInstance.play(url: nextTrack.mediaURL)
            currentTrack = nextTrack
        } else {
            currentIndex = 0
            AudioPlayer.sharedInstance.isPaused = false
            let nextTrack = trackPlaylist[currentIndex]
            AudioPlayer.sharedInstance.play(url: nextTrack.mediaURL)
            currentTrack = nextTrack
        }
    }
}

enum PlayerStatus {
    case waitingToPlay
    case playing
    case paused
}

