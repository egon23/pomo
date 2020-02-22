//
//  InterfaceController.swift
//  pomoWatch Extension
//
//  Created by Egon Manya on 20.02.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var timer: WKInterfaceTimer!
    var wcSession: WCSession?
    @IBOutlet weak var lbl: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        lbl.setText("dfg")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NSLog(message.description)
        timer.stop()
        let sec = message["duration"] as? String ?? "0"
        let action = message["action"] as? String
        
        lbl.setText(action)
        if action == "RUNNING" {
            timer.setDate(Date(timeIntervalSinceNow: Double(sec)!-1))
            timer.start()
        }
    }

}
