//
//  AddTaskViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

struct Taskk{
    
    var name: String
    var estimatedHours: Float
    var date: String
    var hoursWorked: Float
    
    init(name: String, estimatedHours: Float) {
        self.name = name
        self.estimatedHours = estimatedHours
        date = "01.01.20"
        hoursWorked = 0
    }
}

protocol AddTaskDelegate {
    func addTask(task: Taskk)
}

import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var titelTextField: UITextField!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    var vc: TasksSettingsViewController?
    
    var delegate: AddTaskDelegate?
    
    @IBAction func createButtonTouched(_ sender: UIButton) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Create new task"
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
   
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
