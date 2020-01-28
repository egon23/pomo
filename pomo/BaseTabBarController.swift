//
//  BaseTabBarController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark

        selectedIndex = defaultIndex
    }

}
