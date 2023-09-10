/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

protocol DatePickerDelegate{
    func dateValueDidChange(sender: DatePicker,date: Date?)
}

class DatePicker : UIView{
    
    private var label = UILabel()
    private var datePicker = UIDatePicker()
    
    var delegate : DatePickerDelegate? = nil
    
    func setupView(labelText: String, date : Date?, minimumDate : Date? = nil){
        label.text = labelText
        addSubview(label)
        datePicker.timeZone = .none
        if let date = date{
            datePicker.date = date
        } else{
            datePicker.date = Date()
        }
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addAction(UIAction(){ action in
            self.delegate?.dateValueDidChange(sender: self,date: self.datePicker.date)
        }, for: .valueChanged)
        addSubview(datePicker)
        label.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        datePicker.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
}
