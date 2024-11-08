/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class InfoViewController: ScrollViewController {
    
    var stackView = UIStackView()
    
    override func loadView() {
        title = "info".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        stackView.axis = .vertical
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        setupInfos()
    }
    
    func setupInfos(){
        
    }
    
    func addBlock() -> InfoBlock{
        let block = InfoBlock()
        stackView.addArrangedSubview(block)
        return block
    }
    
}

typealias InfoBlock = ArrangedSectionView

