//
//  SettingsViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsCell
        
        
        
        switch indexPath.row {
        case 0: cell.settingLabel.text = "Tutorial"
        case 1: cell.settingLabel.text = "Manage Tasks"
        case 2: cell.settingLabel.text = "Intervals"
        case 3: cell.settingLabel.text = "Notifications"
        case 4: cell.settingLabel.text = "Sounds"
        case 5: cell.settingLabel.text = "Appearance"
        case 6: cell.settingLabel.text = "App Icon"
        case 7: cell.settingLabel.text = "About us"
        default:
            cell.textLabel?.text = "?"
        }
        cell.settingLabel.sizeToFit()
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
