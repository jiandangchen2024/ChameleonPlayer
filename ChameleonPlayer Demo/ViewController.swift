//
//  ViewController.swift
//  ChameleonPlayer Demo
//
//  Created by liuyan on 5/12/16.
//  Copyright © 2016 Eyepetizer Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 120, height: 60)
        button.setTitle("播放", for: UIControlState())
        button.backgroundColor = UIColor.red
        self.view.addSubview(button)
        
        button.addTarget(
            self,
            action: #selector(ViewController.playButtonTapActionHandler(_:)),
            for: .touchUpInside
        )
    }
    
    @objc func playButtonTapActionHandler(_ button: UIButton) {
        let viewController = PlayerViewController()
        self.present(viewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


