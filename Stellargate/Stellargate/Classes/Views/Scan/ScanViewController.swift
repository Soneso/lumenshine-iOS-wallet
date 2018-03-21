//
//  ScanViewController.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanViewControllerDelegate: class {
    func setQR(value: String)
}

class ScanViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    weak var delegate: ScanViewControllerDelegate?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        captureSession.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCamera()
    }
    
    func setupView() {
        navigationItem.backButton.tintColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = "Scanning..."
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
        view.backgroundColor = Stylesheet.color(.black)
    }
    
    @objc
    func dismissView() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupCamera() {
        var deviceTypes:[AVCaptureDevice.DeviceType]
        if #available(iOS 10.2, *) {
            deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
        } else {
            deviceTypes = [.builtInWideAngleCamera]
        }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("No Camera Found.")
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
            qrCodeFrameView.layer.borderColor = Stylesheet.color(.green).cgColor
            qrCodeFrameView.layer.borderWidth = 3.0
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    func showAlert(qrCode: String) {
        let alert = UIAlertController(title: "Valid QR Code Found", message: qrCode, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(),
                                      style: .cancel,
                                      handler: { action in
            self.dismissView()
        }))
        present(alert, animated: true)
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let qrValue =  metadataObj.stringValue {
                delegate?.setQR(value: qrValue)
                captureSession.stopRunning()
                
                navigationItem.titleLabel.text = "Valid QR Code Found"
                showAlert(qrCode:qrValue)
            }
        }
    }
}

