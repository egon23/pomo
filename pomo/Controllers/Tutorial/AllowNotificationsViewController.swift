//
//  AllowNotificationsViewController.swift
//  pomo
//
//  Created by roli on 04.02.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import UserNotifications

class AllowNotificationsViewController: UIViewController, UNUserNotificationCenterDelegate {

     let notificationCenter = UNUserNotificationCenter.current()
    
    @IBAction func btnTouched(_ sender: Any) {
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
