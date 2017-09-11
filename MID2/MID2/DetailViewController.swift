//
//  DetailViewController.swift
//  MID2
//
//  Created by Todd Dick on 4/9/17.
//  Copyright © 2017 MIDTEAM. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

/* this function comes from http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift. It allows for any page with a keyboard to be dismissed when tapped outside of text fields, buttons, keyboard.  Just add self.hideKeyboardWhenTappedAround() into viewDidLoad() */
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class DetailViewController: UIViewController, AVAudioRecorderDelegate, UITextViewDelegate {
    
    
    var audioRecorder: AVAudioRecorder?
    var textDelegate: UITextViewDelegate?
    var urlText: String?
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var speechAuth: UITextView!
    
    @IBAction func sendButton(_ sender: UIButton) {
        if let detail = detailItem {
            let title = sendButton.currentTitle!
            switch title {
            case "Record":
                if audioRecorder?.isRecording == false {
                    audioRecorder?.record()
                    print("recording might be started")
                    textView.text = "Recording..."
                    sendButton.isSelected = false
                    sendButton.setTitle("Stop", for: .normal)
                    detail.buttonText = "Stop"
                }
            case "Stop":
                if audioRecorder?.isRecording == true {
                    audioRecorder?.stop()
                    print("recording stopped")
                    sendButton.isSelected = false
                    textView.text = "You recorded something. Tap Transcribe to transcribe it."
                    detail.transcription = textView.text!
                    sendButton.setTitle("Transcribe", for: .normal)
                    detail.buttonText = "Transcribe"
                }
            case "Transcribe":
                if detail.speechRecAuth{
                    transcribeNow()
                    
                } else {
                    speechAuth.isHidden = false
                    speechAuth.isEditable = false
                    speechAuth.text = "Transcription disabled. The text block is now editable. Tap send when done."
                    textView.isEditable = true
                    sendButton.isSelected = false
                    sendButton.setTitle("Send", for: .normal)
                    detail.buttonText = "Send"
                }
            case "Send":
                if !detail.done {
                    speechAuth.isHidden = true
                    textView.text = detail.transcription!
                    sendNow()
                    sendButton.isEnabled = false
                    detail.textEditable = false
                    detail.done = true
                }
                else {
                    sendButton.isEnabled = false
                }
            default:
                print("Stop showing fucking errors")
            }
            detail.transcription = textView.text
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        self.hideKeyboardWhenTappedAround()
        // Set up recorder
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let soundFileUrl = dirPaths[0].appendingPathComponent("sound.caf")
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, AVEncoderBitRateKey: 16,
                              AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileUrl, settings: recordSettings as [String: AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error \(error.localizedDescription)")
        }
        textView.delegate = self
        audioRecorder?.delegate = self

        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                print("name = \(detail.name!)")
                let date = detail.timestamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm EEE, MMM dd,yyyy"
                label.text = dateFormatter.string(from: date! as Date)
                
                textView.isEditable = detail.textEditable
                textView.text = detail.transcription
                
                sendButton.setTitle(detail.buttonText, for: .normal)
                sendButton.setTitleColor(UIColor.red, for: .normal)
                
                speechAuth.isHidden = true
                
            }
        }
        sendButton.isEnabled = true;
        
        authorizeSR()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        let alert = UIAlertController(title: "Set IP", message: "", preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        //
        //        }))
        //        alert.addTextField(configurationHandler: { (textField: UITextField!) in
        //            textField.placeholder = "http://xxx.xx.xx.xxx:8000/post/new/"
        //            self.inputText = textField
        //        })
        //
        //        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record encode error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
    }
    
    func authorizeSR() {
        if let detail = detailItem {
            SFSpeechRecognizer.requestAuthorization { authStatus in OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    detail.speechRecAuth = true
                case .denied:
                    detail.speechRecAuth = false
                case .restricted:
                    detail.speechRecAuth = false
                case .notDetermined:
                    detail.speechRecAuth = false
                }
                }
            }
            
        }
    }
    
    func transcribeNow() {
        sendButton.isEnabled = false
        self.textView.text = "Transcribing..."
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: (self.audioRecorder?.url)!)
        recognizer?.recognitionTask(with: request) {(result, error) in guard result != nil else {
            print(error?.localizedDescription as Any)
            //need proper error handling here
            self.detailItem?.buttonText = "Record"
            self.detailItem?.transcription = "There was a problem with the recording.\nPlease record your idea again."
            self.configureView()
            return
            }
            if (result?.isFinal)!{
                self.detailItem?.transcription = result?.bestTranscription.formattedString
                self.textView.text = self.detailItem?.transcription
                self.speechAuth.isHidden = false
                self.speechAuth.isEditable = false
                self.speechAuth.text = "The text block is now editable. Tap send when done."
                self.textView.isEditable = true
                self.sendButton.isSelected = false
                self.sendButton.isEnabled = true
                self.sendButton.setTitle("Send", for: .normal)
                self.detailItem?.buttonText = "Send"
            }
        }
    }
    
    
    
    func sendNow() {
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        let parameters = ["text": self.detailItem?.transcription!, "author": self.detailItem?.name!] as! Dictionary<String, String>
        
        //get the URL (pre-release)
        let defaults = UserDefaults.standard
        let urlText = defaults.string(forKey: "url")
        
        
        //print("input text : \(String(describing: inputText?.text!))!")
        let url = URL(string: urlText!)
        
        
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url!)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error?.localizedDescription))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        print("This tvdc function triggered")
        if let detail = detailItem {
            let transcription = self.textView.text!
            print("transcription: \(transcription)\n")
            detail.transcription = transcription
            print("transcribe function: \(detail.transcription!)\n")
        }
    }
    
}

