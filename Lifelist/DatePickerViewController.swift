//
//  DatePickerViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/26/19.
//  Copyright © 2019 Jonathan Arbogast. All rights reserved.
//

import Foundation
import UIKit

protocol DatePickerViewControllerDelegate: class {
    func didPick(date: Date)
}

final class DatePickerViewController: UIViewController {
    weak var delegate: DatePickerViewControllerDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.didPick(date: datePicker.date)
    }
    
}
