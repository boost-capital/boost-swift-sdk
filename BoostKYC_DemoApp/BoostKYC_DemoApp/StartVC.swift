//
//  StartVC.swift
//  BoostKYC_DemoApp
//
//  Created by Oleh Hrechyn on 06.11.2025.
//  Copyright © 2025 Boost Capital. All rights reserved.
//

import UIKit
import BoostKYC

class StartVC: UIViewController {
    @IBOutlet weak var beginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BKYC.shared.configure(apiKey: "your_api_key_here")
        BKYC.shared.eventDelegate = self
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        showBottomMenu(from: sender)
    }
}

private extension StartVC {
    func showBottomMenu(from sender: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cambodia ID Card", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.openSDK(for: .idCard)
        }))
        alert.addAction(UIAlertAction(title: "Passport", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.openSDK(for: .passport)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func openSDK(for type: BKYCDocumentType) {
        
        BKYC.shared.startVerification(for: type, flow: .sync) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                case .success:
                    self.showAlert(title: "Success", message: "Status: DONE")
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - BKYCEventDelegate
extension StartVC: BKYCEventDelegate {
    func boostKYC(didCapturePhoto photoData: Data, for documentType: BKYCDocumentType) {
        print("StartVC received intermediate photo! Type: \(documentType.rawValue), Size: \(photoData.count / 1024) kilobytes")
    }
}
