//
//  TaskPickerViewController.swift
//  pomo
//
//  Created by Egon Manya on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import Foundation
import UIKit

class TaskPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tasks.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == taskPicker {
            return tasks[row]
        }
        return " "
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: tasks[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }

    @IBOutlet weak var taskPicker: UIPickerView!
    
    let tasks = ["chill", "sleep", "eat", "gym"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskPicker.delegate = self
        taskPicker.dataSource = self
    }
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
