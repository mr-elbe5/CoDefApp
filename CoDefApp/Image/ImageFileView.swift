/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ImageFileView : UIImageView{
    
    var imageFile : ImageFile
    
    init(imageFile: ImageFile){
        self.imageFile = imageFile
        super.init(image: imageFile.getImage())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

