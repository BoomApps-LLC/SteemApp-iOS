//
//  QRReaderView.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 3/23/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import QRCodeReader

class MyReaderView: UIView, QRCodeReaderDisplayable {
    let cameraView: UIView = {
        let cv = QRReaderView.loadView()
        
        cv.clipsToBounds                             = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        return cv
    }()
    
    lazy var cancelButton: UIButton? = {
        return (cameraView as! QRReaderView).closeButton
    }()
    
    var overlayView: UIView?
    var switchCameraButton: UIButton?
    var toggleTorchButton: UIButton?
    
    private weak var reader: QRCodeReader?
    
    func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool, reader: QRCodeReader?) {
        self.reader               = reader
        //reader?.lifeCycleDelegate = self
        
        addComponents()
        
        cancelButton?.isHidden       = !showCancelButton
        switchCameraButton?.isHidden = !showSwitchCameraButton
        toggleTorchButton?.isHidden  = !showTorchButton
        overlayView?.isHidden        = !showOverlayView
        
        let views = ["cv": cameraView]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        reader?.previewLayer.frame = bounds
    }
    
    // MARK: - Scan Result Indication
    
    @objc func orientationDidChange() {
        setNeedsDisplay()
        
        overlayView?.setNeedsDisplay()
        
        if let connection = reader?.previewLayer.connection, connection.isVideoOrientationSupported {
            let application                    = UIApplication.shared
            let orientation                    = UIDevice.current.orientation
            let supportedInterfaceOrientations = application.supportedInterfaceOrientations(for: application.keyWindow)
            
            connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: orientation, withSupportedOrientations: supportedInterfaceOrientations, fallbackOrientation: connection.videoOrientation)
        }
    }
    
    // MARK: - Convenience Methods
    
    private func addComponents() {
        addSubview(cameraView)
        
        if let reader = reader {
            print("reader", reader.previewLayer)
            cameraView.layer.insertSublayer(reader.previewLayer, at: 0)
            
            orientationDidChange()
        }
    }
}

class QRReaderView: UIView {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var overlayImageView: UIImageView!
    
    static func loadView() -> QRReaderView {
        let nibs = Bundle.main.loadNibNamed("QRReaderView", owner: self, options: nil)
        let nib = nibs?.first(where: { view -> Bool in
            return view is QRReaderView
        })
        
        return (nib as? QRReaderView)!
    }
}
