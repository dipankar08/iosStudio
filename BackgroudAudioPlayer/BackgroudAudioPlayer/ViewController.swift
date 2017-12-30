//
//  ViewController.swift
//  BackgroudAudioPlayer
//
//  Created by Dipankar Dutta on 12/30/17.
//  Copyright © 2017 Dipankar Dutta. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "sample", ofType: "mp3")!))
            player.prepareToPlay();
        }
        catch{
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func restart(_ sender: Any) {
        if player.isPlaying{
            player.currentTime = 0;
            player.play()
        } else{
            
        }
    }
    
    @IBAction func pause(_ sender: Any) {
        if player.isPlaying{
            player.pause();
        } else{
            
        }
    }
    
    @IBAction func play(_ sender: Any) {
        player.play()
    }
}

