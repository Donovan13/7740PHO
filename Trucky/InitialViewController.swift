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
    let locationController = LocationService.sharedInstance
    
    var player: AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Load the video from the app bundle.
        let videoURL: URL = Bundle.main.url(forResource: "background", withExtension: "mp4")!
        
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        backgroundView.layer.addSublayer(playerLayer)
        player?.play()
        
        //loop video
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(InitialViewController.loopVideo),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: nil)
    }
    func loopVideo() {
        player?.seek(to: kCMTimeZero)
//        player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
}
