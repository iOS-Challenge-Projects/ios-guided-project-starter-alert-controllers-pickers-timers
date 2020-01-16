//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
    
    private let countdown = Countdown()
    
    lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
    
    
    //Convert the total of minutes to seconds and add the picked seconds
    private var duration: TimeInterval {
        //conver from minutes + second to total seconds
        let minuteString = countdownPicker.selectedRow(inComponent: 0)
        let secondString = countdownPicker.selectedRow(inComponent: 2)
        
        let minutes = Int(minuteString)
        let seconds = Int(secondString)
        
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        
        return totalSeconds
    }
    
    //this is a special computer property with the () only will be call once
    var dateFormatter: DateFormatter = {
        let formarter = DateFormatter()
        formarter.dateFormat = "HH: mm:ss.SS"
        formarter.timeZone = TimeZone(secondsFromGMT: 0)
        return formarter
    }()
    
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set ourself as delegate
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        
        
        //Set a defalt number when we open the app
        countdownPicker.selectRow(1,inComponent: 0,animated: false)
        countdownPicker.selectRow(30,inComponent:2,animated: false)
        
        countdown.delegate = self
        
        //load the current duration
        countdown.duration = duration
        
        //use a fixed font width so the counter donw shrink and expand ex. 1 vs 2
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)
        
        //Make the buttons's corners rounded
        startButton.layer.cornerRadius = 4.0
        resetButton.layer.cornerRadius = 4.0
        
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
    }
    
    private func timerFinished(timer: Timer){
        showAlert()
    }
    
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        
        //Creating the Alert
        let alert = UIAlertController(title: "Timer Finished", message: "Your countdown is over", preferredStyle: .alert)
        
        //Creating the action button, handler can be use to run some code
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        //Finaly we can present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
//        startButton.disable = true
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
        
    }
    
    private func string(from duration: TimeInterval) -> String {
       let date = Date(timeIntervalSinceReferenceDate: duration)
        
        return dateFormatter.string(from: date)
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()    }
    
    func countdownDidFinish() {
        updateViews()
         showAlert()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    
    //This is how many columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
 
        //In this case we return the amoun of items in our array of arrays
        return countdownPickerData.count
    }
    
    //This is how many rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
 
        //Since we have different columns we access each "component" and count
        //the amount of itmes in it to set the correct amount of rows
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    
    //Inserting values to the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //Here we access each column and each row to set values
        let timeValue = countdownPickerData[component][row]
 
        //then we return the values
        return String(timeValue)
    }
    
    //Set the width for each column
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    //Here we set the pick amount of minutes and seconds by settings it equal
    // to the computed property duration which adds up the minutes and seconds
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
        updateViews()
    }
    
}
