//
//  ViewController.swift
//  wildCard
//
//  Created by Dipankar Dutta on 12/30/17.
//  Copyright © 2017 Dipankar Dutta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    var leftScore:Int = 0
    var rightScrore:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func viewTapped(_ sender: Any) {
        let leftRandom = arc4random_uniform(12)+2
        let rightRandom = arc4random_uniform(12)+2
        print("Left random is : \(leftRandom)")
        print("Left random is : \(rightRandom)")
        if(leftRandom < rightRandom){
            leftScore += 1
        } else{
            rightScrore += 1
        }
        leftImageView.image = UIImage(named:"card\(leftRandom)")
        rightImageView.image = UIImage(named:"card\(rightRandom)")
        leftLabel.text = String(leftScore)
        rightLabel.text = String(rightScrore)
        
    }
}

