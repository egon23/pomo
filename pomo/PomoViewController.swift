//
//  SecondViewController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import CoreData
//import UIDrawer

class PomoViewController: UIViewController, CountdownTimerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var tasks: [Task] = []
    public var selectedTask: Task?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Task")) as! [Task]
        
        self.tasks = data
    }

    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var seconds: UILabel!
    @IBOutlet weak var counterView: UIStackView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var taskField: UITextField!

    var myPicker: UIPickerView! = UIPickerView()
    @IBAction func changeTask(_ sender: Any) {
        taskField.becomeFirstResponder()
    }
    
    func addSecond(){
        selectedTask?.workedHours = (selectedTask?.workedHours ?? 0) + 1
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

    
    //MARK - Vars
    
    var countdownTimerDidStart = false
    
    lazy var countdownTimer: CountdownTimer = {
        let countdownTimer = CountdownTimer()
        return countdownTimer
    }()
    
    
    // Test, for dev
    let selectedSecs:Int = 12
    
    
    lazy var messageLabel: UILabel = {
        let label = UILabel(frame:CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Done!"
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        countdownTimer.delegate = self
        countdownTimer.setTimer(hours: 0, minutes: 0, seconds: selectedSecs)
        progressBar.setProgressBar(hours: 0, minutes: 0, seconds: selectedSecs)
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
        
        view.addSubview(messageLabel)
        
        var constraintCenter = NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenter)
        constraintCenter = NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenter)
        
        messageLabel.isHidden = true
        counterView.isHidden = false
    }
    
    //MARK: - Countdown Timer Delegate
    
    func countdownTime(time: (hours: String, minutes: String, seconds: String)) {
    
        minutes.text = time.minutes
        seconds.text = time.seconds
        selectedTask?.workedHours += 0.01
    }
    
    
    func countdownTimerDone() {
        
        counterView.isHidden = true
        messageLabel.isHidden = false
        seconds.text = String(selectedSecs)
        countdownTimerDidStart = false
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
        startBtn.setTitle("START",for: .normal)
        progressBar.stop()
        
        updateData()
        print("countdownTimerDone")
    }
    
    func updateData() {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "name = %@", selectedTask!.name!)
        
        do {
            let test = try UIApplication.appDelegate.managedContext?.fetch(fetchRequest)
            
            let objectUpdate = test?[0] as! Task
            objectUpdate.workedHours = selectedTask!.workedHours
            print(objectUpdate.workedHours)
            do {
                UIApplication.appDelegate.saveContext()
            }
            catch {
                print(error)
            }
        }
        catch {
            print(error)
        }
            
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        messageLabel.isHidden = true
        counterView.isHidden = false
        
        stopBtn.isEnabled = true
        stopBtn.alpha = 1.0
        
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
    
    @IBAction func stopTimer(_ sender: UIButton) {
        countdownTimer.stop()
        progressBar.stop()
        countdownTimerDidStart = false
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
        startBtn.setTitle("START",for: .normal)
        print(selectedTask?.workedHours)
    }
//    @IBAction func showTasks(_ sender: UIButton) {
//        let viewController = storyboard?.instantiateViewController(identifier: "TaskPickerViewController") as! TaskPickerViewController
//        viewController.modalPresentationStyle = .custom
//        viewController.transitioningDelegate = self
//        self.present(viewController, animated: true)
//    }
//
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return DrawerPresentationController(presentedViewController: presented, presenting: presenting, blurEffectStyle: .dark)
//    }
}

//
//extension PomoViewController: DrawerPresentationControllerDelegate {
//    func drawerMovedTo(positio""n: DraweSnapPoint) {
//
//    }
//}
