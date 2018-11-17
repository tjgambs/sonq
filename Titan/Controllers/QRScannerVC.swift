//
//  QRScannerVC.swift
//  Titan
//
//  Created by Cody Dietrich on 2/18/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import AVFoundation
import UIKit


class QRScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the camera and prepare it to scan for QR Codes.
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.insertSublayer(previewLayer!, below: qrCodeFrameView?.layer)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            captureSession.startRunning()
        } catch {}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Before we appear, start up the camera.
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Before we segue, stop running the camera.
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Executes when a QR code is found.
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            // Vibrate the phone to say that a QR code was found.
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            //************************************************************************//
            //*******// TODO: Confirm the scanned barcode to be a real Party //*******//
            //************************************************************************//
            
            // Set the scanned barcode value as the party ID. This will be used as a way to add songs to the queue.
            Globals.partyDeviceId = stringValue
            DispatchQueue.main.async {
                // Segue to the JoinParty View
                self.performSegue(withIdentifier: "JoinParty", sender: self)
            }
        }
    }
    
}
