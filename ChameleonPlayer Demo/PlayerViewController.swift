//
//  PlayerViewController.swift
//  ChameleonPlayer
//
//  Created by liuyan on 5/24/16.
//  Copyright © 2016 Eyepetizer Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var vrPlayer: VRVideoPlayerView?
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let player = AVPlayer(URL: NSURL(string: "http://baobab.wdjcdn.com/1464062027434Canyon.mp4")!)
        self.player = player
        let vrPlayer = VRVideoPlayerView(AVPlayer: player)
        vrPlayer.frame = self.view.bounds
        vrPlayer.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.view.addSubview(vrPlayer)
        
        self.vrPlayer = vrPlayer
        
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 10, y: 10, width: 120, height: 60)
        self.view.addSubview(button)
        button.setTitle("关闭", forState: .Normal)
        button.addTarget(
            self,
            action: #selector(PlayerViewController.closeButtonTapActionHandler(_:)),
            forControlEvents: .TouchUpInside
        )
        
        let playButton = UIButton(type: .Custom)
        playButton.frame = CGRect(x: 150, y: 10, width: 120, height: 60)
        self.view.addSubview(playButton)
        playButton.setTitle("播放", forState: .Normal)
        playButton.addTarget(
            self,
            action: #selector(PlayerViewController.playButtonTapActionHandler(_:)),
            forControlEvents: .TouchUpInside
        )
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.vrPlayer?.play()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func closeButtonTapActionHandler(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playButtonTapActionHandler(sender: UIButton) {
        self.vrPlayer?.play()
    }

}
