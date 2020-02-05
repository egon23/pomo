//
//  AddTaskViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//


import UIKit


protocol AddTaskDelegate {
    func addTaskWillDismissed()
    
}

class AddTaskViewController: UIViewController {

    @IBOutlet weak var titelTextField: UITextField!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveBtn: UIButton!
    var del: AddTaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = navigationController?.navigationBar {
            nav.prefersLargeTitles = true
            navigationItem.title = "Create new task"
            saveBtn.isHidden = true
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func saveTaskPressed(_ sender: UIButton) {
        saveTask()
    }
    
    @IBAction func barSaveButton(_ sender: UIBarButtonItem) {
        saveTask()
    }
    
    func saveTask() {
        if !titelTextField.text!.isEmpty && !hoursTextField.text!.isEmpty {
            let task: Task = Task(context: UIApplication.appDelegate.managedContext!)
            task.name = titelTextField.text ?? "New Task"
            task.estimatedHours = Double(hoursTextField.text ?? "0")!
            task.deadline = datePicker.date
            UIApplication.appDelegate.saveContext()
            if saveBtn.isHidden {
                self.navigationController?.popViewController(animated: true)
            } else {
                del?.addTaskWillDismissed()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
