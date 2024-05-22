/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import PDFKit
import MessageUI

class PDFViewController: BaseViewController {
    
    var pdfView = PDFView()
    
    var pdfCreator = PDFRenderer()
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    func setupView() {
        let guide = view.safeAreaLayoutGuide
        view.addSubviewWithAnchors(pdfView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor)
        let data = createPDF()
        let document = PDFDocument(data: data)
        pdfView.document = document
        pdfView.autoScales = true
        
        let saveButton = TextButton(text: "save".localize())
        saveButton.addAction(UIAction(){ action in
            self.showAccept(title: "saveReport".localize(),text: "selectReportFile".localize(), onAccept: {
                self.save(data: data)
            })
        }, for: .touchDown)
        view.addSubviewAtTopCentered(saveButton, topView: pdfView, insets: defaultInsets)
        
        let sendButton = TextButton(text: "send".localize())
        sendButton.addAction(UIAction(){ action in
            self.send(data: data)
        }, for: .touchDown)
        view.addSubviewAtTopCentered(sendButton, topView: saveButton, insets: defaultInsets)
            .bottom(view.bottomAnchor, inset:  -2*defaultInset)
        
    }
    
    func createPDF() -> Data{
        fatalError("not implemented")
    }
    
    func getFileName() -> String{
        "\(title!)_\(Date.localDate.shortFileDate()).pdf"
    }
    
    func save(data: Data){
        let url = FileController.tmpDirURL.appendingPathComponent(getFileName())
        FileController.saveFile(data: data, url: url)
        var urls = [URL]()
        urls.append(url)
        let documentPickerController = UIDocumentPickerViewController(
            forExporting: urls)
        self.present(documentPickerController, animated: true, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func send(data: Data){
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients(["you@yoursite.com"])
            mailController.setSubject("reportSubject".localize())
            mailController.setMessageBody("<p>\("reportAttached".localize())</p>", isHTML: true)
            mailController.addAttachmentData(data, mimeType: "application/pdf", fileName: getFileName())
            present(mailController, animated: true)
        } else {
            self.showError("mailNotConfigured".localize())
        }
    }
    
}

extension PDFViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        switch result{
        case .sent:
            showDone(title: "mailSent".localize(), text: "mailSentText".localize())
        case .failed:
            showError("mailErrorText".localize())
        default:
            return
        }
    }
    
}
