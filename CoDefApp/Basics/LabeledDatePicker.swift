/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

class LabeledDatePicker : UIView{
    
    private var label = UILabel()
    private var datePicker = UIDatePicker()
    
    var date: Date{
        get{
            return datePicker.date
        }
        set{
            datePicker.date = newValue
        }
    }
    
    func setupView(labelText: String, date: Date = Date()){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        datePicker.backgroundColor = .systemBackground
        datePicker.setRoundedBorders()
        datePicker.date = date
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        addSubview(datePicker)
        
        label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        datePicker.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
    }
    
    func setMinMaxDate(minDate: Date, maxDate: Date){
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
    }
    
}
