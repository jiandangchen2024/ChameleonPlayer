//
//  VRVideoPlayerView.swift
//  ChameleonPlayer
//
//  Created by liuyan on 4/29/16.
//  Copyright © 2016 Eyepetizer Inc. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion

private class VRVideoNode: SKVideoNode {
    
    fileprivate var pasueLocked: Bool = false
    
    fileprivate override var isPaused: Bool {
        get {
            return super.isPaused
        }
        set(newValue) {
            if pasueLocked == false {
                super.isPaused = newValue
                pasueLocked = true
            }
        }
    }
    
    fileprivate override func play() {
        super.play()
        self.pasueLocked = false
        self.isPaused = false
    }
    
    fileprivate override func pause() {
        super.pause()
        self.pasueLocked = false
        self.isPaused = true
    }
    
}

open class VRVideoPlayerView: UIView {
    
    fileprivate weak var sceneView: SCNView?
    
    fileprivate weak var videoSKNode: VRVideoNode?
    
    fileprivate weak var videoNode: SCNNode?
    fileprivate weak var cameraNode: SCNNode?
    fileprivate weak var cameraPitchNode: SCNNode?
    fileprivate weak var cameraRollNode: SCNNode?
    fileprivate weak var cameraYawNode: SCNNode?
    
    fileprivate var isPaning: Bool = false
    fileprivate var firstFocusing: Bool = false
    
    open var panGestureRecognizer: UIPanGestureRecognizer? {
        willSet(newValue) {
            if let currentGR = self.panGestureRecognizer {
                self.removeGestureRecognizer(currentGR)
            }
            if let panGR = newValue {
                panGR.removeTarget(nil, action: nil)
                panGR.addTarget(
                    self,
                    action: #selector(VRVideoPlayerView.panGestureRecognizerHandler(_:))
                )
                panGR.delegate = self
                self.addGestureRecognizer(panGR)
            }
        }
    }
    
    open var panSensitiveness: Float = 150
    open var panEnable: Bool = true
    open var motionEnable: Bool = true {
        didSet(oldValue) {
            guard self.superview != nil else {
                return
            }
            
            if self.motionEnable != oldValue {
                if self.motionEnable == true {
                    self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
                } else {
                    self.motionManager.stopDeviceMotionUpdates()
                }
            }
        }
    }
    
    fileprivate var motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1 / 60.0
        return motionManager
    }()
    
    fileprivate var cameraNodeAngle: SCNVector3 {
        let cameraNodeAngleX: Float = Float(-M_PI_2)
        var cameraNodeAngleY: Float = 0.0
        var cameraNodeAngleZ: Float = 0.0
        
        switch UIApplication.shared.statusBarOrientation.rawValue {
        case 1:
            cameraNodeAngleY = Float(-M_PI_2)
        case 2:
            cameraNodeAngleY = Float(M_PI_2)
        case 3:
            cameraNodeAngleZ = Float(M_PI)
        default:
            break
        }
        
        return SCNVector3(x: cameraNodeAngleX, y: cameraNodeAngleY, z: cameraNodeAngleZ)
    }
    fileprivate var currentCameraAngle: (pitch: Float, yaw: Float, roll: Float) = (0, 0, 0)
    fileprivate var currentAttitudeAngle: (pitch: Float, yaw: Float, roll: Float) = (1.5, 0, 0)
    
    open var pasued: Bool {
        if let pasued = self.videoSKNode?.isPaused {
            return pasued
        }
        return true
    }
    
    public init(AVPlayer player: AVPlayer) {
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        UIDevice.orientationDidChangeNotification
        self.setupScene()
        self.setupVideoSceneWithAVPlayer(player)
        self.videoSKNode?.pause()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.cameraNode?.eulerAngles = self.cameraNodeAngle
        self.observeNotifications()
        if self.motionEnable {
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.unobserveNotifications()
            self.motionManager.stopDeviceMotionUpdates()
        }
    }
    
    deinit {
        self.unobserveNotifications()
        self.videoSKNode?.removeFromParent()
        self.videoNode?.geometry?.firstMaterial?.diffuse.contents = nil
        if let rootNode = self.sceneView?.scene?.rootNode {
            func removeChildNodesInNode(_ node: SCNNode) {
                for node in node.childNodes {
                    removeChildNodesInNode(node)
                }
            }
            removeChildNodesInNode(rootNode)
        }
    }
    
}

//MARK: Setup
private extension VRVideoPlayerView {
    
    func setupScene() {
        // Create Scene View
        let sceneView = SCNView(frame: self.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = UIColor.black
        self.sceneView = sceneView
        self.addSubview(sceneView)
        
        // Create Scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Create Cameras
        let camera = SCNCamera()
        camera.zFar = 50.0
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Zero
        self.cameraNode = cameraNode
        
        let cameraPitchNode = SCNNode()
        cameraPitchNode.addChildNode(cameraNode)
        
        let cameraRollNode = SCNNode()
        cameraRollNode.addChildNode(cameraPitchNode)
        
        let cameraYawNode = SCNNode()
        cameraYawNode.addChildNode(cameraRollNode)
        
        self.cameraPitchNode = cameraPitchNode
        self.cameraRollNode = cameraRollNode
        self.cameraYawNode = cameraYawNode
        
        self.cameraPitchNode?.eulerAngles.x = 1.5
        self.cameraYawNode?.eulerAngles.y = 1.5
        
        sceneView.scene?.rootNode.addChildNode(cameraYawNode)
        sceneView.pointOfView = cameraNode
        
        sceneView.delegate = self
        sceneView.isPlaying = true
        
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.isUserInteractionEnabled = true
    }
    
    func setupVideoSceneWithAVPlayer(_ player: AVPlayer) {
        let spriteKitScene = SKScene(size: CGSize(width: 2500, height: 2500))
        spriteKitScene.scaleMode = .aspectFit
        
        let videoSKNode = VRVideoNode(avPlayer: player)
        videoSKNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        videoSKNode.size = spriteKitScene.size
        self.videoSKNode = videoSKNode
        
        spriteKitScene.addChild(videoSKNode)
        
        let videoNode = SCNNode()
        videoNode.geometry = SCNSphere(radius: 50)
        videoNode.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        videoNode.geometry?.firstMaterial?.isDoubleSided = true
        
        var transform = SCNMatrix4MakeRotation(Float(M_PI), 0, 0, 1)
        transform = SCNMatrix4Translate(transform, 1, 1, 0)
        
        videoNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 0, -1, 0)
        videoNode.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        videoNode.position = SCNVector3(x: 0, y: 0, z: 0)
        videoNode.rotation = SCNVector4Make(1, 1, 1, 0)
        self.sceneView?.scene?.rootNode.addChildNode(videoNode)
        self.videoNode = videoNode
    }
    
}

//MARK: SceneRenderer Delegate
extension VRVideoPlayerView: SCNSceneRendererDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if self.isPaning == false {
            DispatchQueue.main.async {
                if let currentAttitude = self.motionManager.deviceMotion?.attitude {
                    let roll: Float = {
                        if UIApplication.shared.statusBarOrientation == .landscapeRight {
                            return -1.0 * Float(-M_PI - currentAttitude.roll)
                        } else {
                            return Float(currentAttitude.roll)
                        }
                    }()
                    
                    //because of landscape
                    self.currentAttitudeAngle.pitch = roll
                    self.currentAttitudeAngle.yaw = Float(currentAttitude.yaw)
                    self.currentAttitudeAngle.roll = Float(currentAttitude.pitch)
                    
                    if self.firstFocusing == false {
                        self.currentCameraAngle.pitch = (self.currentAttitudeAngle.pitch - 1.5) * self.panSensitiveness
                        self.currentCameraAngle.yaw = (self.currentAttitudeAngle.yaw - 1.5) * self.panSensitiveness
                        self.firstFocusing = true
                    }
                    
                    self.cameraPitchNode?.eulerAngles.x = (self.currentAttitudeAngle.pitch
                        - self.currentCameraAngle.pitch / self.panSensitiveness)
                    self.cameraYawNode?.eulerAngles.y = (self.currentAttitudeAngle.yaw
                        - self.currentCameraAngle.yaw / self.panSensitiveness)
                    self.cameraRollNode?.eulerAngles.z = self.currentAttitudeAngle.roll
                }
            }
        }
    }
    
}

//MARK: GestureRecognizer Handler
extension VRVideoPlayerView: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.panEnable
    }
    
    @objc public func panGestureRecognizerHandler(_ panGR: UIPanGestureRecognizer) {
        if let panView = panGR.view {
            let translation = panGR.translation(in: panView)
            
            var newAngleYaw = Float(translation.x)
            var newAnglePitch = Float(translation.y)
            
            //current angle is an instance variable so i am adding the newAngle to it
            newAnglePitch += self.currentCameraAngle.pitch
            newAngleYaw += self.currentCameraAngle.yaw
            
            self.cameraPitchNode?.eulerAngles.x = self.currentAttitudeAngle.pitch - newAnglePitch / self.panSensitiveness
            self.cameraYawNode?.eulerAngles.y = self.currentAttitudeAngle.yaw - newAngleYaw / self.panSensitiveness
            
            switch panGR.state {
            case .began:
                self.isPaning = true
                
            case .cancelled, .ended, .failed:
                self.isPaning = false
                currentCameraAngle.pitch = newAnglePitch
                currentCameraAngle.yaw = newAngleYaw
                
            default:
                break
            }
        }
    }
    
}

//MARK: Player Control
public extension VRVideoPlayerView {
    
    func play() {
        videoSKNode?.play()
    }
    
    func pause() {
        videoSKNode?.pause()
    }
    
    func focuseCenter() {
        self.currentCameraAngle.pitch = (self.currentAttitudeAngle.pitch - 1.5) * self.panSensitiveness
        self.currentCameraAngle.yaw = (self.currentAttitudeAngle.yaw - 1.5) * self.panSensitiveness
        
        self.cameraPitchNode?.eulerAngles.x = 1.5
        self.cameraYawNode?.eulerAngles.y = 1.5
    }
    
}

//MARK: Notification
extension VRVideoPlayerView {
    
    fileprivate func observeNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(VRVideoPlayerView.applicationDidChangeStatusBarOrientationNotificationHandler(_:)),
            name: UIApplication.didChangeStatusBarOrientationNotification,
            object: nil
        )
    }
    
    fileprivate func unobserveNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(
            self,
            name: UIApplication.didChangeStatusBarOrientationNotification,
            object: nil
        )
    }
    
    @objc func applicationDidChangeStatusBarOrientationNotificationHandler(_ notification: Notification?) {
        if UIApplication.shared.applicationState == .active {
            self.cameraNode?.eulerAngles = self.cameraNodeAngle
        }
    }
    
}
