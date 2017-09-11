//
//  LoginController.swift
//  MID2
//
//  Created by Todd Dick on 5/4/17.
//  Copyright © 2017 MIDTEAM. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBAction func logIn(_ sender: Any) {
        defaults.set(userName.text, forKey: "userName")
        defaults.set(passWord.text, forKey: "passWord")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = defaults.string(forKey: "userName")
        passWord.text = defaults.string(forKey: "passWord")
        self.hideKeyboardWhenTappedAround()
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
