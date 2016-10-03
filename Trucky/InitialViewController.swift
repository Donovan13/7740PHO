//
//  InitialViewController.swift
//  Trucky
//
//  Created by Kyle on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVKit
import AVFoundation

class InitialViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    let firebaseController = FirebaseController.sharedConnection
    
    var player: AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the video from the app bundle.
        let videoURL: NSURL = NSBundle.mainBundle().URLForResource("background", withExtension: "mp4")!
        
        player = AVPlayer(URL: videoURL)
        player?.actionAtItemEnd = .None
        player?.muted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        backgroundView.layer.addSublayer(playerLayer)
        player?.play()
        
        //loop video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(InitialViewController.loopVideo),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
    }
    func loopVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
}
