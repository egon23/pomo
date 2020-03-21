//
//  CountdownTimer.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit


/// interface to update UI on timer change
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
    
    /// sets a duration to the timer delegate
    /// - Parameters:
    ///   - hours: amount of hours
    ///   - minutes: amount of minutes
    ///   - seconds: amount of seconds
    public func setTimer(hours:Int, minutes:Int, seconds:Int) {
        
        let hoursToSeconds = hours * 3600
        let minutesToSeconds = minutes * 60
        let secondsToSeconds = seconds
        
        let seconds = secondsToSeconds + minutesToSeconds + hoursToSeconds
        self.seconds = Double(seconds)
        self.duration = Double(seconds)
        
        delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
    }
    
    /// starts the timer
    public func start() {
        runTimer()
    }
    
    /// pause the timer
    public func pause() {
        timer.invalidate()
    }
    
    /// stops the timer and resets delegate
    public func stop() {
        timer.invalidate()
        duration = seconds
        delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
    }
    
    /// returns the current duration of the timer
    public func getDuratiion() -> Double {
        return duration
    }
    
    /// starts the timer and adds an observer method which will be called after every seconds
    fileprivate func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    /// if the timer is running this method updates the delegate with the current duration
    @objc fileprivate func updateTimer(){
        if duration < 0.0 {
            timer.invalidate()
            timerDone()
        } else {
            duration -= 1
            delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
        }
    }
    
    /// converts timeInterval to string
    /// - Parameter time: current time
    fileprivate func timeString(time:TimeInterval) -> (hours: String, minutes:String, seconds:String) {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return (
            hours: hours < 0 ? "00" : String(format:"%02i", hours),
            minutes: minutes < 0 ? "00" : String(format:"%02i", minutes),
            seconds: seconds < 0 ? "00" : String(format:"%02i", seconds))
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
    
    /// if a savedTime exists, it calculates the time when the was in background and updates duration and delegate
    func resumeFromBackground() -> TimeInterval {
        if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
            let timeInBackground = Date().timeIntervalSince(savedDate)
            duration -= timeInBackground
            delegate?.countdownTime(time: timeString(time: TimeInterval(ceil(duration))))
            return timeInBackground
        }
        return 0
    }
    
}


