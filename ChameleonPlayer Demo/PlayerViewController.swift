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
        let player = AVPlayer(url: URL(string: "http://baobab.wdjcdn.com/1464062027434Canyon.mp4")!)
        self.player = player
        let vrPlayer = VRVideoPlayerView(AVPlayer: player)
        vrPlayer.frame = self.view.bounds
        vrPlayer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(vrPlayer)
        
        self.vrPlayer = vrPlayer
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 10, y: 10, width: 120, height: 60)
        self.view.addSubview(button)
        button.setTitle("关闭", for: UIControlState())
        button.addTarget(
            self,
            action: #selector(PlayerViewController.closeButtonTapActionHandler(_:)),
            for: .touchUpInside
        )
        
        let playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 150, y: 10, width: 120, height: 60)
        self.view.addSubview(playButton)
        playButton.setTitle("播放", for: UIControlState())
        playButton.addTarget(
            self,
            action: #selector(PlayerViewController.playButtonTapActionHandler(_:)),
            for: .touchUpInside
        )
        
        self.observeNotifcations()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.vrPlayer?.play()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    func closeButtonTapActionHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func playButtonTapActionHandler(_ sender: UIButton) {
        self.vrPlayer?.play()
    }

}

extension PlayerViewController {
    
    fileprivate func observeNotifcations() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(PlayerViewController.applicationDidBecomeActiveNotificationHandler(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(PlayerViewController.applicationWillResginActiveNotificationHandler(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil
        )
    }
    
    fileprivate func unobserveNotifications() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func applicationDidBecomeActiveNotificationHandler(_ notification: Notification) {
        guard UIApplication.shared.applicationState != UIApplicationState.background else {
            return
        }
        self.vrPlayer?.play()
    }
    
    func applicationWillResginActiveNotificationHandler(_ notification: Notification) {
        UIApplication.shared.isIdleTimerDisabled = false
        self.vrPlayer?.pause()
    }
    
}
