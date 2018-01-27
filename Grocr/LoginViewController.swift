/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override func viewDidLoad() {
    
    let rootRef = Database.database().reference()
    let childRef = Database.database().reference(withPath: "grocery-items")
    let itemsRef = rootRef.child("grocery-items")
    let milkRef = itemsRef.child("milk")
    
    print(rootRef.key)
    print(childRef.key)
    print(itemsRef.key)
    print(milkRef.key)
    
    let listener = Auth.auth().addStateDidChangeListener {
      auth, user in
        if user != nil {
          self.performSegue(withIdentifier: self.loginToList, sender: nil)
        }
      }
    Auth.auth().removeStateDidChangeListener(listener)
    
  }
  
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    Auth.auth().signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!)
    performSegue(withIdentifier: loginToList, sender: nil)
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { action in
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
      Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
        user, error in
        if error != nil {
          if let errorCode = AuthErrorCode(rawValue: error!._code) {
            switch errorCode {
            case .weakPassword:
              print("Please provide a strong password")
            default:
              print("There is an error")
            }
          }
        }
        if user != nil {
          user?.sendEmailVerification() {
            error in
            print(error?.localizedDescription ?? "")
          }
          Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!)
          self.performSegue(withIdentifier: self.loginToList, sender: nil)
        }
      }
                                
                                  
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
