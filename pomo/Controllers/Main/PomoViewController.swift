//
//  SecondViewController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class PomoViewController: UIViewController, CountdownTimerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, AddTaskDelegate, WCSessionDelegate {
    
    enum timerStates: String {
        case RUNNING = "RUNNING"
        case PAUSED = "PAUSED"
        case STOPPED = "STOPPED"
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
    var wcSession: WCSession?
    var didReceiveMessageFromWatch = false
    var isPomoSkipped = false
    var titleText = ""
    
    lazy var countdownTimer: CountdownTimer = {
        let countdownTimer = CountdownTimer()
        return countdownTimer
    }()
    
    @IBOutlet weak var progressBar: ProgressBarView!
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
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateApplication(noti:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Task")) as! [Task]
        self.tasks = data
        if let task = selectedTask {
            if !tasks.contains(task) {
                taskField.text = "Select a task"
                startBtn.isEnabled = false
            }
        }
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
            day?.intervals = 0
            day?.tasks = []
        }
    }
    
    func addTaskWillDismissed() {
        self.viewWillAppear(true)
        myPicker.selectRow(0, inComponent: 0, animated: false)
        setTask(sender: startBtn)
    }
    
    // MARK: - PickerView for Tasks
    var myPicker: UIPickerView! = UIPickerView()
    @IBAction func changeTask(_ sender: Any) {
        if !tasks.isEmpty {
            taskField.becomeFirstResponder()
        } else {
        }
    }
    
    /// shows PickerView
    /// - Parameter sender: button
    @IBAction func selectTask(_ sender: UITextField) {
        if !tasks.isEmpty {
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
        } else {
            showAddTaskView(sender: sender)
        }
        
    }
    
    @objc func cancelPicker(sender:UIButton) {
        //Remove view when select cancel
        self.taskField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    /// set current task
    /// - Parameter sender: <#sender description#>
    @objc func setTask(sender:UIButton) {
        taskField.text = tasks[myPicker.selectedRow(inComponent: 0)].name
        self.taskField.resignFirstResponder() // To resign the inputView on clicking done.
        selectedTask = tasks[myPicker.selectedRow(inComponent: 0)]
        startBtn.isEnabled = true
        if day == nil || !Calendar.current.isDateInToday((day?.date!)!) {
            setCurrentDay()
        }
        stopTimer(stopBtn)
    }
    
    func showAddTaskView(sender: UITextField) {
        sender.inputView?.isHidden = true
        sender.resignFirstResponder() // To resign the inputView on clicking done.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = storyboard.instantiateViewController(identifier: "AddTaskViewController") as! AddTaskViewController
        modalVC.del = self
        self.present(modalVC, animated: true, completion: nil)
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
        DispatchQueue.main.async {
            self.minutes.text = time.minutes
            self.seconds.text = time.seconds
        }
        updateData(sec: 1)
    }
    
    
    func countdownTimerDone() {
        countdownTimerState = timerStates.STOPPED
        setupCountdownTimer()
        countdownTimer.removeSavedDate()
        DispatchQueue.main.async {
            self.stopBtn.isEnabled = false
            self.startBtn.setTitle("START",for: .normal)
            self.progressBar.stop()
        }
        if !isPomoSkipped && !isTimeForBreak {
            day?.intervals += 1
            UIApplication.appDelegate.saveContext()
        }
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
        var timeInMinutes = pomoTimeInMinutes
        if isTimeForBreak {
            timeInMinutes = shortBreakTimeInMinutes
            titleText = "Break"
            isTimeForBreak = false
            if pomoCycleCounter == 4 {
                timeInMinutes = longBreakTimeInMinutes
                pomoCycleCounter = 0
            }
        } else {
            pomoCycleCounter += 1
            titleText = "\(pomoCycleCounter). Pomodoro"
            isTimeForBreak = true
        }
        DispatchQueue.main.async {
            self.cycleCountLabel.isHidden = false
            self.cycleCountLabel.text = self.titleText
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
        DispatchQueue.main.async {
            self.stopBtn.isEnabled = true
            self.nextBtn.isEnabled = true
        }
        if countdownTimerState == timerStates.RUNNING {
            countdownTimerState = timerStates.PAUSED
            DispatchQueue.main.async {
                self.countdownTimer.pause()
                self.progressBar.pause()
                self.startBtn.setTitle("RESUME",for: .normal)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
            }
        } else {
            countdownTimerState = timerStates.RUNNING
            DispatchQueue.main.async {
                self.countdownTimer.start()
                self.progressBar.start()
                self.startBtn.setTitle("PAUSE",for: .normal)
                self.setNotification(notificationType: self.cycleCountLabel.text!)
            }
        }
        if !didReceiveMessageFromWatch {
            setWatchTimer(sec: countdownTimer.getDuratiion())
        }
    }
    
    @IBAction func skipCycle(_ sender: UIButton) {
        isPomoSkipped = true
        countdownTimer.stop()
        countdownTimerDone()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
        isPomoSkipped = false
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        countdownTimerState = timerStates.STOPPED
        isTimeForBreak = false
        pomoCycleCounter = 0
        DispatchQueue.main.async {
            self.countdownTimer.stop()
            self.progressBar.stop()
            self.stopBtn.isEnabled = false
            self.nextBtn.isEnabled = false
            self.startBtn.setTitle("START",for: .normal)
        }
        setupCountdownTimer()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timmerDone"])
        if !didReceiveMessageFromWatch {
            setWatchTimer(sec: countdownTimer.getDuratiion())
        }
        print(selectedTask?.workedHours ?? 0)
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        if countdownTimerState == timerStates.RUNNING {
            let shared = UserDefaults.standard
            shared.set(Date(), forKey: "savedTime")
        }
    }
    
    @objc func willEnterForeground(noti: Notification) {
        if countdownTimerState == timerStates.RUNNING {
            let timeInBackground = countdownTimer.resumeFromBackground()
            updateData(sec: timeInBackground)
        }
    }
    
    @objc func willTerminateApplication(noti: Notification) {
        if wcSession?.isPaired ?? false && wcSession?.isWatchAppInstalled ?? false {
            wcSession?.sendMessage(["action":"TERMINATED"], replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
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
    
    func setWatchTimer(sec:Double) {
        if wcSession?.isPaired ?? false && wcSession?.isWatchAppInstalled ?? false {
            wcSession?.sendMessage(["action":countdownTimerState.rawValue, "duration":sec.description, "title":cycleCountLabel.text ?? ""], replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as! String == "true" {
            didReceiveMessageFromWatch = true
            if message["action"] as! String == timerStates.STOPPED.rawValue {
                stopTimer(stopBtn)
            } else if message["action"] as! String == "SKIP" {
                skipCycle(nextBtn)
            } else if !(message["action"] as! String).isEmpty {
                startTimer(startBtn)
            }
            replyHandler(["action":countdownTimerState.rawValue, "duration":countdownTimer.getDuratiion().description, "title":titleText])
        }
        didReceiveMessageFromWatch = false
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")}
}
