/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ImageFileView : UIImageView{
    
    var imageFile : ImageData
    
    init(imageFile: ImageData){
        self.imageFile = imageFile
        super.init(image: imageFile.getImage())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

