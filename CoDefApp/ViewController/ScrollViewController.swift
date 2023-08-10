/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ScrollViewController: BaseViewController {
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    var scrollVertical : Bool = true
    var scrollHorizontal : Bool = false
    
    
    override func loadView() {
        super.loadView()
        
        setupViews()
    }
    
    func setupViews(){
        let guide = view.safeAreaLayoutGuide
        view.addSubviewWithAnchors(scrollView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        setupScrollView()
    }
    
    func setupScrollView(){
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        scrollView.addSubviewWithAnchors(contentView, top: scrollView.topAnchor, leading: scrollView.leadingAnchor)
        if scrollVertical{
            contentView.bottom(scrollView.bottomAnchor)
        }
        else{
            contentView.height(scrollView.heightAnchor)
        }
        if scrollHorizontal{
            contentView.trailing(scrollView.trailingAnchor)
        }
        else{
            contentView.width(scrollView.widthAnchor)
        }
        setupContentView()
    }
    
    func setupContentView(){
        
    }
    
    func updateContentView(){
        contentView.removeAllSubviews()
        setupContentView()
    }
    
    func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(stopEditing))
        scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardDidShow(notification:NSNotification){
        if let firstResponder = contentView.firstResponder{
            let rect : CGRect = firstResponder.frame
            var parentView = firstResponder.superview
            var offset : CGFloat = 0
            while parentView != nil && parentView != scrollView {
                offset += parentView!.frame.minY
                parentView = parentView?.superview
            }
            scrollView.scrollRectToVisible(.init(x: rect.minX, y: rect.minY + offset, width: rect.width, height: rect.height), animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @objc func stopEditing(){
        if let sv = scrollView.firstResponder{
            sv.resignFirstResponder()
        }
    }
    
}


