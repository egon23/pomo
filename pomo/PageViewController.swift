//
//  PageViewController.swift
//  pomo
//
//  Created by roli on 04.02.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: "pageView") else {
            return
        }
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
