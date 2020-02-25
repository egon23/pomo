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
    
    @IBOutlet weak var startBtn: WKInterfaceButton!
    @IBOutlet weak var stopBtn: WKInterfaceButton!
    @IBOutlet weak var skipBtn: WKInterfaceButton!
    @IBOutlet weak var cycleLabel: WKInterfaceLabel!
    @IBOutlet weak var timer: WKInterfaceTimer!
    var wcSession: WCSession?
    var state = "STOPPED"
    
    var pomoTimeInMinutes: Double = 25
    var shortBreakTimeInMinutes: Int = 5
    var longBreakTimeInMinutes: Int = 20
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        stopBtn.setEnabled(false)
        skipBtn.setEnabled(false)
        pomoTimeInMinutes = UserDefaults.standard.object(forKey: "pomoLength") as? Double ?? 25
        shortBreakTimeInMinutes = UserDefaults.standard.object(forKey: "shortBreakLength") as? Int ?? 5
        longBreakTimeInMinutes = UserDefaults.standard.object(forKey: "longBreakLength") as? Int ?? 20
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        requestActionOnPhone(action: "")
    }
    
    fileprivate func requestActionOnPhone(action: String) {
        if WCSession.isSupported() && wcSession?.isReachable ?? false && wcSession?.isCompanionAppInstalled ?? false {
            wcSession?.sendMessage(["request" : "true", "action" : action], replyHandler: { (response) in
                self.setTimer(response)
            }, errorHandler: { (error) in
                print("Error sending message: %@", error)
            })
        } else {
            requirePhoneApp()
        }
    }
    
    fileprivate func requirePhoneApp() {
        cycleLabel.setText("iPhone app not reachable!")
        timer.setDate(Date(timeIntervalSinceNow: pomoTimeInMinutes*60+1))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        
        NSLog("sessionReachabilityDidChange " + session.isReachable.description)
        if !session.isReachable {
            requirePhoneApp()
        }
    }
    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        
        NSLog("sessionCompanionAppInstalledDidChange " + session.isCompanionAppInstalled.description)
    }
    fileprivate func setTimer(_ message: [String : Any]) {
        timer.stop()
        state = message["action"] as! String
        if state == "TERMINATED" {
            requirePhoneApp()
        } else {
            let sec = message["duration"] as? String ?? "0"
            let title = message["title"] as? String
            cycleLabel.setText(title)
            timer.setDate(Date(timeIntervalSinceNow: Double(sec)!-1))
            if state == "RUNNING" {
                timer.start()
                stopBtn.setEnabled(true)
                skipBtn.setEnabled(true)
                startBtn.setTitle("Pause")
            } else if state == "PAUSED" {
                startBtn.setTitle("Resume")
            } else if state == "STOPPED" {
                timer.setDate(Date(timeIntervalSinceNow: Double(sec)!+1))
                startBtn.setTitle("Start")
                stopBtn.setEnabled(false)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        setTimer(message)
    }
    
    @IBAction func startTouched() {
        requestActionOnPhone(action: "RUNNING")
    }
    
    @IBAction func stopTouched() {
        requestActionOnPhone(action: "STOPPED")
    }
    
    @IBAction func skipTouched() {
        requestActionOnPhone(action: "SKIP")
    }
}
