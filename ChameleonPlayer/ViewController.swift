//
//  ViewController.swift
//  ChameleonPlayer
//
//  Created by liuyan on 4/29/16.
//  Copyright © 2016 Eyepetizer Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fileURL = NSURL(string: "http://cache.utovr.com/201512140211024506.mp4")
        let player = AVPlayer(URL: fileURL!)
        let videoPlayerView = VRVideoPlayerView(AVPlayer: player)
        self.view.addSubview(videoPlayerView)
        videoPlayerView.frame = self.view.bounds
        
        videoPlayerView.motionEnable = true
        
        videoPlayerView.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

