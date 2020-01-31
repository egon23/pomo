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
    
    var countdownTimeInMinutes: Int = 1
    var pomoCycleCounter = 0
    var countdownTimerDidStart = false
    var isTimeForBreak = false
    
    lazy var countdownTimer: CountdownTimer = {
        let countdownTimer = CountdownTimer()
        return countdownTimer
    }()
    
    var tasks: [Task] = []
    public var selectedTask: Task?
    
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
        selectedTask?.workedHours += 0.01
    }
    
    
    func countdownTimerDone() {
        countdownTimerDidStart = false
        stopBtn.isEnabled = false
        startBtn.setTitle("START",for: .normal)
        progressBar.stop()
        countdownTimer.removeSavedDate()
        
        updateData()
        print("countdownTimerDone")
        startTimer(startBtn)
    }
    
    func updateData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "name = %@", selectedTask!.name!)
        
        do {
            let test = try UIApplication.appDelegate.managedContext?.fetch(fetchRequest)
            
            let objectUpdate = test?[0] as! Task
            objectUpdate.workedHours = selectedTask!.workedHours
            print(objectUpdate.workedHours)
            UIApplication.appDelegate.saveContext()
        } catch {
            print(error)
        }
            
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        cycleCountLabel.isHidden = false
        stopBtn.isEnabled = true
        nextBtn.isEnabled = true
        if isTimeForBreak {
            countdownTimeInMinutes = 5
            cycleCountLabel.text = "Break"
            isTimeForBreak = false
            if pomoCycleCounter == 4 {
                countdownTimeInMinutes = 15
                pomoCycleCounter = 0
            }
        } else {
            countdownTimeInMinutes = 25
            pomoCycleCounter += 1
            cycleCountLabel.text = "\(pomoCycleCounter). Pomodoro"
            isTimeForBreak = true
        }
        countdownTimer.setTimer(hours: 0, minutes: countdownTimeInMinutes, seconds: 0)
        progressBar.setProgressBar(hours: 0, minutes: countdownTimeInMinutes, seconds: 0)
        startTimerCycle()
    }
    
    func startTimerCycle() {
        if !countdownTimerDidStart{
            countdownTimer.start()
            progressBar.start()
            countdownTimerDidStart = true
            startBtn.setTitle("PAUSE",for: .normal)
        }else{
            countdownTimer.pause()
            progressBar.pause()
            countdownTimerDidStart = false
            startBtn.setTitle("RESUME",for: .normal)
        }
    }
    @IBAction func skipCycle(_ sender: UIButton) {
        countdownTimer.stop()
        countdownTimerDone()
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        countdownTimer.stop()
        progressBar.stop()
        countdownTimerDidStart = false
        isTimeForBreak = false
        cycleCountLabel.isHidden = true
        pomoCycleCounter = 0
        stopBtn.isEnabled = false
        nextBtn.isEnabled = false
        startBtn.setTitle("START",for: .normal)
        countdownTimer.setTimer(hours: 0, minutes: 25, seconds: 0)
        progressBar.setProgressBar(hours: 0, minutes: 25, seconds: 0)
        print(selectedTask?.workedHours ?? 0)
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        if countdownTimerDidStart {
            print("hthz")
            let shared = UserDefaults.standard
            shared.set(Date(), forKey: "savedTime")
        }
    }
    
    @objc func willEnterForeground(noti: Notification) {
        if countdownTimerDidStart {
            print("ffh")
            countdownTimer.resumeFromBackground()
        }
    }
    
}
