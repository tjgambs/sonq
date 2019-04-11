//
//  QRScannerViewController.swift
//  sonq
//
//  Created by Tim Gamble on 4/6/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftyJSON
import SwiftRandom

class QRScannerViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    @IBOutlet weak var backButton: UIButton!
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            return
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession.startRunning()
        
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
            view.addSubview(backButton)
            view.bringSubviewToFront(backButton)
        }
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeRightAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeRightAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func afterRegistration(partyId: String) {
        SonqAPI.getParty(partyId: partyId)
            .done { value -> Void in
                Globals.partyId = partyId
                let json = JSON(value)
                Globals.partyId = partyId
                
                if (json["device_id"].stringValue == Globals.deviceId!) {
                    Globals.isHost = true
                } else {
                    Globals.isHost = false
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "JoinParty", sender: self)
                }
            }
            .catch { error in
                print(error.localizedDescription)
                self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if metadataObj.stringValue != nil {
                let partyId = metadataObj.stringValue!
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                captureSession.stopRunning()
                
                SonqAPI.getDevice()
                    .done { value -> Void in
                        let json = JSON(value)
                        Globals.deviceName = json["username"].stringValue
                        self.afterRegistration(partyId: partyId)
                    }
                    .catch { error in
                        Globals.deviceName = Randoms.randomFakeName()
                        SonqAPI.postDevice()
                            .done { value -> Void in
                                self.afterRegistration(partyId: partyId)
                            }
                            .catch { error in
                                print(error.localizedDescription)
                        }
                }
            }
        }
    }
    
}
