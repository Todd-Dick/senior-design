//
//  SettingsViewController.swift
//  MID2
//
//  Created by Todd Dick on 5/4/17.
//  Copyright © 2017 MIDTEAM. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var example: UILabel!
    
    @IBAction func setURL(_ sender: Any) {
        defaults.set(urlField.text, forKey: "url")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        urlField.text = defaults.string(forKey: "url")
        example.text = "http://xxx.xx.xx.xxx:8000/post/new/"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
