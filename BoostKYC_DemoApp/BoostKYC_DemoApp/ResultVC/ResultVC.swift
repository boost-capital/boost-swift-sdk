//
//  ResultVC.swift
//  BoostKYC_DemoApp
//
//  Created by Oleh Hrechyn on 10.11.2025.
//  Copyright © 2025 Boost Capital. All rights reserved.
//

import UIKit

final class ResultVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    
    private var rows: [ResultRow] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func display(data: [String: Any]) {
        rows = ResultRow.build(from: data)
    }
}

// MARK: - Setup & Actions
private extension ResultVC {
    func setupInitialUI() {
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "HeaderCell")
        tableView?.dataSource = self
    }
}


// MARK: - UITableViewDataSource
extension ResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = rows[indexPath.row]
        
        switch rowModel {
            case .header(let title):
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
                cell.textLabel?.text = title
                cell.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
                cell.backgroundColor = .lightGray
                cell.selectionStyle = .none
                return cell
                
            case .keyValue(let key, let value):
                let cellId = "KeyValueCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .value1, reuseIdentifier: cellId)
                
                cell.textLabel?.text = key
                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                cell.textLabel?.textColor = .darkGray
                
                cell.detailTextLabel?.text = value
                cell.detailTextLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                cell.detailTextLabel?.textColor = .gray
                cell.detailTextLabel?.numberOfLines = 0
                
                cell.selectionStyle = .none
                return cell
        }
    }
}
