//
//  TMModeSettingTableViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMModeSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var modalNavBar: UINavigationItem!
    
    // MARK: - @IBActions
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)

    }
    
    var hidesBackButton = true
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = hidesBackButton
//        if !hidesBackButton {
//            navigationItem.setRightBarButton(nil, animated: true)
//        }
    }
    
    deinit {
        print(self, "deinit!")
    }
}
