//
//  ViewController.swift
//  Midterm-Karanveer
//
//  Created by Karanveer Singh on 2/12/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var soundPlayer: AVAudioPlayer?
    
    @IBAction func unwindToViewController(sender: UIStoryboardSegue){
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        soundPlayer?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let soundURL = Bundle.main.path(forResource: "bg-music", ofType: "mp3")
        let url = URL(fileURLWithPath: soundURL!)
      
        self.soundPlayer = try! AVAudioPlayer.init(contentsOf: url)
        self.soundPlayer?.currentTime = 0
        self.soundPlayer?.volume = 0.5
        self.soundPlayer?.numberOfLoops = -1
        self.soundPlayer?.play()
    }
}
