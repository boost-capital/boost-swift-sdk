//
//  StartVC.swift
//  BoostKYC_DemoApp
//
//  Created by Oleh Hrechyn on 06.11.2025.
//  Copyright © 2025 Boost Capital. All rights reserved.
//

import UIKit
import BoostKYC

enum DemoFlow {
    case sync
    case async
}

class StartVC: UIViewController {
    @IBOutlet weak var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let apiKey = "your_api_key_here"
        BackendEmulator.shared.configure(apiKey: apiKey)
        BKYC.shared.configure(apiKey: apiKey)
        BKYC.shared.eventDelegate = self
    }
    
    @IBAction func syncFlowButtonPressed(_ sender: UIButton) {
        showBottomMenu(from: sender, flow: .sync)
    }
    
    @IBAction func asyncFlowButtonPressed(_ sender: UIButton) {
        showBottomMenu(from: sender, flow: .async)
    }
}

private extension StartVC {
    func showBottomMenu(from sender: UIView, flow: DemoFlow) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cambodia ID Card", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self.openSDK(for: .idCard, flow: flow)
            }))
            alert.addAction(UIAlertAction(title: "Passport", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self.openSDK(for: .passport, flow: flow)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }
    
    func openSDK(for type: BKYCDocumentType, flow: DemoFlow) {
        switch flow {
            case .sync:
                startSyncFlowSDK(for: type)
            case .async:
                createSessionForFlowSDK(for: type)
            @unknown default:
                break
        }
        
    }
    
    func startSyncFlowSDK(for type: BKYCDocumentType) {
        BKYC.shared.startVerification(for: type) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                case .success:
                    self.showAlert(title: "Success", message: "Status: DONE")
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func createSessionForFlowSDK(for type: BKYCDocumentType) {
        BackendEmulator.shared.createSession { [weak self] result in
            switch result {
                case .success(let token):
                    self?.startAsyncFlowSDK(for: type, sessionToken: token)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func startAsyncFlowSDK(for type: BKYCDocumentType, sessionToken: String) {
        
        BKYC.shared.startVerification(for: type, sessionToken: sessionToken) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                case .success:
                    self.displayAllData(for: sessionToken)
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func displayAllData(for sessionToken: String) {
        switchLoading(true)
        
        BackendEmulator.shared.getFullResults(token: sessionToken) { [weak self] result in
            guard let self else { return }
            self.switchLoading(false)
            
            switch result {
                case .success(let json):
                    self.showResultVC(data: json)
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func showResultVC(data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let resultVC = ResultVC()
            resultVC.modalPresentationStyle = .fullScreen
            resultVC.display(data: data)
            self.present(resultVC, animated: true)
        }
    }
    
    func switchLoading(_ isOn: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.loadingView?.alpha = isOn ? 1 : 0
            }, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - BKYCEventDelegate
extension StartVC: BKYCEventDelegate {
    func boostKYC(didCapturePhoto photoData: Data, for documentType: BKYCDocumentType) {
        print("StartVC received intermediate photo! Type: \(documentType.rawValue), Size: \(photoData.count / 1024) kilobytes")
    }
}
