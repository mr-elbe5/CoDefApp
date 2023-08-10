/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class CheckboxGroupView: UIView{
    
    var selectedIndex : Int = -1
    var selectedValue : String{
        if selectedIndex != -1{
            return checkboxViews[selectedIndex].title
        }
        return ""
    }
    
    var onOffCheckbox = CheckboxGroupIcon()
    var checkboxViews = Array<Checkbox>()
    var stackView = UIStackView()
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        stackView.axis = .vertical
        stackView.alignment = .leading
        addSubviewFilling(stackView)
        onOffCheckbox.setup(isOn: true)
        onOffCheckbox.checkboxIcon.delegate = self
        stackView.addArrangedSubview(onOffCheckbox)
    }
    
    func addCheckbox(cb: Checkbox){
        checkboxViews.append(cb)
        stackView.addArrangedSubview(cb)
    }
    
    func select(index: Int){
        selectedIndex = index
        for radioView in checkboxViews{
            radioView.isOn = radioView.index == index
        }
    }
    
}

extension CheckboxGroupView: OnOffIconDelegate{
    
    func onOffValueDidChange(icon: OnOffIcon) {
        if icon == onOffCheckbox.checkboxIcon{
            for cb in checkboxViews{
                cb.isOn = icon.isOn
            }
        }
    }
    
}

class CheckboxGroupIcon: UIView{
    
    var checkboxIcon = CheckboxIcon()
    var isOn: Bool{
        get{
            checkboxIcon.isOn
        }
        set{
            checkboxIcon.isOn = newValue
        }
    }
    
    func setup(isOn: Bool = false){
        self.isOn = isOn
        addSubviewFilling(checkboxIcon, insets: defaultInsets)
    }
    
}
