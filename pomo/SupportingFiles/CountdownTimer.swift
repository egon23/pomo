//
//  CountdownTimer.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

protocol CountdownTimerDelegate:class {
    func countdownTimerDone()
    func countdownTime(time: (hours: String, minutes:String, seconds:String))
}

class CountdownTimer {
    
    weak var delegate: CountdownTimerDelegate?
    
    fileprivate var seconds = 0.0
    fileprivate var duration = 0.0
    
    var diffHrs = 0
    var diffMins = 0
    var diffSecs = 0

    lazy var timer: Timer = {
        let timer = Timer()
        return timer
    }()
    
    public func setTimer(hours:Int, minutes:Int, seconds:Int) {
        
        let hoursToSeconds = hours * 3600
        let minutesToSeconds = minutes * 60
        let secondsToSeconds = seconds
        
        let seconds = secondsToSeconds + minutesToSeconds + hoursToSeconds
        self.seconds = Double(seconds)
        self.duration = Double(seconds)
        
        delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
    }
    
    public func start() {
        runTimer()
    }
    
    public func pause() {
        timer.invalidate()
    }
    
    public func stop() {
        timer.invalidate()
        duration = seconds
        delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
    }
    
    public func getDuratiion() -> Double {
        return duration
    }
    
    fileprivate func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateTimer(){
        if duration < 0.0 {
            timer.invalidate()
            timerDone()
        } else {
            duration -= 1
            delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
        }
    }
    
    fileprivate func timeString(time:TimeInterval) -> (hours: String, minutes:String, seconds:String) {
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return (hours: String(format:"%02i", hours), minutes: String(format:"%02i", minutes), seconds: String(format:"%02i", seconds))
    }
    
    fileprivate func timerDone() {
        timer.invalidate()
        duration = seconds
        delegate?.countdownTimerDone()
    }
    
    
    func removeSavedDate() {
        if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
            UserDefaults.standard.removeObject(forKey: "savedTime")
        }
    }
    
    func resumeFromBackground() -> Double {
        if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
            let timeInBackground = CountdownTimer.getTimeDifference(startDate: savedDate)
            duration -= timeInBackground
            delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
            return timeInBackground
        }
        return 0
    }
    
    static func getTimeDifference(startDate: Date) -> Double {
       let calendar = Calendar.current
       let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
       return Double((components.hour! * 3600) + (components.minute! * 60) + components.second!)
    }
    
    
}


