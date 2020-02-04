//
//  SecondViewController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import CoreData

class PomoViewController: UIViewController, CountdownTimerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    enum timerStates {
        case RUNNING
        case PAUSED
        case STOPPED
    }
    var pomoTimeInMinutes: Int = 25
    var shortBreakTimeInMinutes: Int = 5
    var longBreakTimeInMinutes: Int = 20
    var pomoCycleCounter = 0
    var countdownTimerState = timerStates.STOPPED
    var isTimeForBreak = false
    var day: Day?
    var tasks: [Task] = []
    var selectedTask: Task?
    
    lazy var countdownTimer: CountdownTimer = {
        let countdownTimer = CountdownTimer()
        return countdownTimer
    }()
    
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var seconds: UILabel!
    @IBOutlet weak var counterView: UIStackView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var taskField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cycleCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        myPicker.delegate = self
        myPicker.dataSource = self
        countdownTimer.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Task")) as! [Task]
        self.tasks = data
        pomoTimeInMinutes = UserDefaults.standard.object(forKey: "pomoLength") as? Int ?? 25
        shortBreakTimeInMinutes = UserDefaults.standard.object(forKey: "shortBreakLength") as? Int ?? 5
        longBreakTimeInMinutes = UserDefaults.standard.object(forKey: "longBreakLength") as? Int ?? 20
    }

    func setCurrentDay() {
        var data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Day")) as! [Day]
        data.sort{ $0.date?.compare($1.date!) == .orderedDescending}

        if data.count > 0 && Calendar.current.isDateInToday(data[0].date!) {
            day = data[0]
            print((day?.date!.description)! + "  " + (day?.workedHoursInSeconds.description)!)
        } else {
            day = Day(context: UIApplication.appDelegate.managedContext!)
            day?.date = Date()
            day?.workedHoursInSeconds = 0.0
            day?.breakMinutesInSeconds = 0.0
            day?.tasks = []
        }
    }
    
    // MARK: - PickerView for Tasks
    var myPicker: UIPickerView! = UIPickerView()
    @IBAction func changeTask(_ sender: Any) {
        taskField.becomeFirstResponder()
    }
    
    @IBAction func selectTask(_ sender: UITextField) {
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        myPicker.tintColor = tintColor
        myPicker.center.x = inputView.center.x
        inputView.addSubview(myPicker) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        doneButton.setTitle("Cancel", for: .normal)
        doneButton.setTitle("Cancel", for: .highlighted)
        doneButton.setTitleColor(tintColor, for: .normal)
        doneButton.setTitleColor(tintColor, for: .highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(cancelPicker), for: .touchUpInside) // set button click event

        let cancelButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: 0, width: 100, height: 50))
        cancelButton.setTitle("Done", for: .normal)
        cancelButton.setTitle("Done", for: .highlighted)
        cancelButton.setTitleColor(tintColor, for: .normal)
        cancelButton.setTitleColor(tintColor, for: .highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(setTask), for: .touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @objc func cancelPicker(sender:UIButton) {
        //Remove view when select cancel
        self.taskField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func setTask(sender:UIButton) {
        //Remove view when select cancel
        taskField.text = tasks[myPicker.selectedRow(inComponent: 0)].name
        self.taskField.resignFirstResponder() // To resign the inputView on clicking done.
        selectedTask = tasks[myPicker.selectedRow(inComponent: 0)]
        startBtn.isEnabled = true
        if day == nil || !Calendar.current.isDateInToday((day?.date!)!) {
            setCurrentDay()
        }
        stopTimer(stopBtn)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tasks.count
    }

    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == myPicker {
            return tasks[row].name
        }
        return " "
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: tasks[row].name ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }

    //MARK: - Countdown Timer Delegate
    
    func countdownTime(time: (hours: String, minutes: String, seconds: String)) {
        minutes.text = time.minutes
        seconds.text = time.seconds
        updateData(sec: 0.01)
    }
    
    
    func countdownTimerDone() {
        countdownTimerState = timerStates.STOPPED
        setupCountdownTimer()
        stopBtn.isEnabled = false
        startBtn.setTitle("START",for: .normal)
        progressBar.stop()
        countdownTimer.removeSavedDate()
        print("countdownTimerDone")
        //startTimer(startBtn)
    }
    
    func updateData(sec: Double) {
        if isTimeForBreak { // pomodoro is not in break mode
            selectedTask?.workedHours += sec
            day?.workedHoursInSeconds += sec
        } else {
            day?.breakMinutesInSeconds += sec
        }
        UIApplication.appDelegate.saveContext()
    }
    
    fileprivate func setupCountdownTimer() {
        cycleCountLabel.isHidden = false
        var timeInMinutes = pomoTimeInMinutes
        if isTimeForBreak {
            timeInMinutes = shortBreakTimeInMinutes
            cycleCountLabel.text = "Break"
            isTimeForBreak = false
            if pomoCycleCounter == 4 {
                timeInMinutes = longBreakTimeInMinutes
                pomoCycleCounter = 0
            }
        } else {
            pomoCycleCounter += 1
            cycleCountLabel.text = "\(pomoCycleCounter). Pomodoro"
            isTimeForBreak = true
        }
        countdownTimer.setTimer(hours: 0, minutes: timeInMinutes, seconds: 0)
        progressBar.setProgressBar(hours: 0, minutes: timeInMinutes, seconds: 0)
        if !(day?.tasks?.contains(selectedTask!))! {
            day?.addToTasks(selectedTask!)
        }
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        if day == nil || !Calendar.current.isDateInToday((day?.date!)!) {
            setCurrentDay()
        }
        stopBtn.isEnabled = true
        nextBtn.isEnabled = true
        if countdownTimerState == timerStates.RUNNING {
            countdownTimer.pause()
            progressBar.pause()
            countdownTimerState = timerStates.PAUSED
            startBtn.setTitle("RESUME",for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
        } else {
            countdownTimer.start()
            progressBar.start()
            countdownTimerState = timerStates.RUNNING
            startBtn.setTitle("PAUSE",for: .normal)
            setNotification(notificationType: cycleCountLabel.text!)
        }
    }
    
    @IBAction func skipCycle(_ sender: UIButton) {
        countdownTimer.stop()
        countdownTimerDone()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        countdownTimer.stop()
        progressBar.stop()
        countdownTimerState = timerStates.STOPPED
        isTimeForBreak = false
        pomoCycleCounter = 0
        stopBtn.isEnabled = false
        nextBtn.isEnabled = false
        startBtn.setTitle("START",for: .normal)
        setupCountdownTimer()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
        print(selectedTask?.workedHours ?? 0)
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        if countdownTimerState == timerStates.RUNNING {
            print("hthz")
            let shared = UserDefaults.standard
            shared.set(Date(), forKey: "savedTime")
        }
    }
    
    @objc func willEnterForeground(noti: Notification) {
        if countdownTimerState == timerStates.RUNNING {
            print("ffh")
            let timeInBackground = countdownTimer.resumeFromBackground()
            updateData(sec: timeInBackground)
        }
    }
    
    func setNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationType + " finished"
        let next = (notificationType.contains("Break")) ? "next Pomodoro" : "Break"
        content.body = "Tap here to start " + next
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: countdownTimer.getDuratiion(), repeats: false)
        let request = UNNotificationRequest(identifier: "timmerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
