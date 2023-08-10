/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import PDFKit

class PDFRenderer {
    
    static var A4Rect = CGRect(x: 0, y: 0, width: 8.2677165354 * 72.0, height: 11.6929133858 * 72.0)
    
    var pageRect = PDFRenderer.A4Rect
    
    var topMargin: CGFloat = 15.0
    var bottomMargin: CGFloat = 15.0
    var indent: CGFloat = 10.0
    var lineMargin: CGFloat = PDFTextType.textSize/4
    var lineSpace: CGFloat = PDFTextType.textSize
    
    //runtime
    var context : UIGraphicsPDFRendererContext? = nil
    var nextTop: CGFloat = 0
    
    var contentLeft: CGFloat{
        indent
    }
    
    var contentWidth: CGFloat{
        pageRect.width - 2*indent
    }
    
    var labelWidth: CGFloat{
        contentWidth * 0.2
    }
    var tableContentLeft: CGFloat{
        indent + labelWidth + indent
    }
    var tableContentWidth: CGFloat{
        contentWidth * 0.8 - indent
    }
    
    var table2ColumnWidth: CGFloat{
        (tableContentWidth - indent)/2
    }
    
    var table2ColumnFirstLeft: CGFloat{
        tableContentLeft
    }
    
    var table2ColumnSecondLeft: CGFloat{
        tableContentLeft + table2ColumnWidth + indent
    }
    
    func scaledImageSize(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize{
        if maxHeight == 0{
            let aspectRatio = maxWidth / image.size.width
            return CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        }
        else{
            let maxWidthRatio = maxWidth / image.size.width
            let maxHeightRatio = maxHeight / image.size.height
            let aspectRatio = min(maxWidthRatio, maxHeightRatio)
            return CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        }
    }
    
    func checkNextTop(height: CGFloat){
        if nextTop + height + bottomMargin > pageRect.height{
            context?.beginPage()
            nextTop = topMargin
        }
    }
    
    func start(title: String){
        let attributedTitle = PDFTextType.attributedText(title, type: .header1)
        let stringSize = attributedTitle.size()
        let height = stringSize.height
        nextTop += PDFTextType.header1Size
        let stringRect = CGRect(x: (pageRect.width - stringSize.width) / 2.0, y: nextTop, width: stringSize.width, height: height)
        attributedTitle.draw(in: stringRect)
        nextTop += height + PDFTextType.header1Size
    }
    
    func addLine(text: String, type: PDFTextType){
        let attributedTitle = PDFTextType.attributedText(text, type: type)
        let stringSize = attributedTitle.size()
        let height = stringSize.height
        checkNextTop(height: height)
        let titleStringRect = CGRect(x: contentLeft, y: nextTop, width: contentWidth, height: height)
        attributedTitle.draw(in: titleStringRect)
        nextTop += height + lineMargin
    }
    
    func addLine(image: UIImage, maxHeight: CGFloat) {
        let imageSize = scaledImageSize(image: image, maxWidth: contentWidth, maxHeight: maxHeight)
        checkNextTop(height: imageSize.height)
        let imageRect = CGRect(x: contentLeft, y: nextTop, width: imageSize.width, height: imageSize.height)
        image.draw(in: imageRect)
        nextTop += imageSize.height + lineMargin
    }
    
    func addLine(label: String, text: String, labelType: PDFTextType = .text, textType: PDFTextType = .text){
        let labelText = PDFTextType.attributedText(label, type: labelType)
        let labelHeight = labelText.height(width: labelWidth)
        let text = PDFTextType.attributedText(text, type: textType)
        let textHeight = text.height(width: tableContentWidth)
        let height = max(labelHeight, textHeight)
        checkNextTop(height: height)
        let labelRect = CGRect(x: contentLeft, y: nextTop, width: labelWidth, height: labelHeight)
        labelText.draw(in: labelRect)
        let textRect = CGRect(x: tableContentLeft, y: nextTop, width: tableContentWidth, height: textHeight)
        text.draw(in: textRect)
        nextTop += height + lineMargin
    }
    
    func addLine(label: String, image: UIImage, maxHeight: CGFloat, labelType: PDFTextType = .text){
        let labelText = PDFTextType.attributedText(label, type: labelType)
        let labelHeight = labelText.height(width: labelWidth)
        let imageSize = scaledImageSize(image: image, maxWidth: tableContentWidth, maxHeight: maxHeight)
        checkNextTop(height: imageSize.height)
        let labelRect = CGRect(x: contentLeft, y: nextTop, width: labelWidth, height: labelHeight)
        let imageRect = CGRect(x: tableContentLeft, y: nextTop, width: imageSize.width, height: imageSize.height)
        labelText.draw(in: labelRect)
        image.draw(in: imageRect)
        nextTop += imageSize.height + lineMargin
    }
    
    func addLine(label: String, images: Array<ImageFile>, maxHeight: CGFloat, labelType: PDFTextType = .text){
        let labelText = PDFTextType.attributedText(label, type: labelType)
        let labelHeight = labelText.height(width: labelWidth)
        let labelRect = CGRect(x: contentLeft, y: nextTop, width: labelWidth, height: labelHeight)
        labelText.draw(in: labelRect)
        for i in 0..<images.count{
            let image = images[i].getImage()
            let imageSize = scaledImageSize(image: image, maxWidth: table2ColumnWidth, maxHeight: maxHeight)
            if i%2 == 0{
                checkNextTop(height: maxHeight)
            }
            let offset = (table2ColumnWidth - imageSize.width)/2
            let imageRect = CGRect(x: (i%2 == 0 ? table2ColumnFirstLeft : table2ColumnSecondLeft) + offset + 1, y: nextTop + 1, width: imageSize.width - 2, height: imageSize.height - 2)
            context?.cgContext.setFillColor(UIColor.black.cgColor)
            context?.fill(CGRect(x: (i%2 == 0 ? table2ColumnFirstLeft : table2ColumnSecondLeft), y: nextTop, width: table2ColumnWidth, height: maxHeight))
            image.draw(in: imageRect)
            if i%2 == 1 || i == images.count - 1{
                nextTop += maxHeight + lineMargin
            }
        }
    }
    
    func addLine(){
        if let ctx = context?.cgContext{
            ctx.setStrokeColor(UIColor.darkGray.cgColor)
            ctx.beginPath()
            ctx.move(to: CGPoint(x: contentLeft, y: nextTop))
            ctx.addLine(to: CGPoint(x: pageRect.width, y: nextTop))
            ctx.strokePath()
            nextTop += 1.0 + lineMargin
        }
    }
    
    func addSpacer(){
        nextTop += lineSpace
    }
    
    func addDoubleSpacer(){
        nextTop += 2*lineSpace
    }
    
}
