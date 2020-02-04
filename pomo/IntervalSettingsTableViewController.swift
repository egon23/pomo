//
//  IntervalSettingsTableViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class IntervalSettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pomoLengthText: UITextField!
    @IBOutlet weak var shortBreakText: UITextField!
    @IBOutlet weak var longBreakText: UITextField!
    var myPicker: UIPickerView! = UIPickerView()
    let minutes: [Int] = Array(1...99)
    var currTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        myPicker.delegate = self
        myPicker.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Intervals"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pomoLengthText.text = (UserDefaults.standard.object(forKey: "pomoLength") as? Int ?? 25).description + " Minutes"
        shortBreakText.text = (UserDefaults.standard.object(forKey: "shortBreakLength") as? Int ?? 5).description + " Minutes"
        longBreakText.text = (UserDefaults.standard.object(forKey: "longBreakLength") as? Int ?? 20).description + " Minutes"
    }
    
    @IBAction func editTime(_ sender: UITextField) {
        sender.becomeFirstResponder()
    }
    
    @IBAction func onEditTextField(_ sender: UITextField) {
        currTextField = sender
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
        cancelButton.addTarget(self, action: #selector(setMinutes), for: .touchUpInside) // set button click event
        sender.inputView = inputView
        
    }
    
    @objc func cancelPicker(sender:UIButton) {
        //Remove view when select cancel
        self.currTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func setMinutes(sender:UIButton) {
        //Remove view when select cancel
        currTextField.text = minutes[myPicker.selectedRow(inComponent: 0)].description + " Minutes"
        currTextField.resignFirstResponder() // To resign the inputView on clicking done.
        let defaults = UserDefaults.standard
        defaults.set(minutes[myPicker.selectedRow(inComponent: 0)], forKey: currTextField.placeholder!)
        defaults.synchronize()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minutes.count
    }

    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == myPicker {
            return minutes[row].description + " Minutes"
        }
        return " "
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: minutes[row].description + " Minutes", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
}
