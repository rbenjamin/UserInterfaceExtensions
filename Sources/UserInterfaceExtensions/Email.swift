//
//  Email.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 12/18/25.
//

#if canImport(MessageUI) && canImport(UIKit)
import SwiftUI
import MessageUI
import UIKit

typealias MailSendResult = ((Result<MFMailComposeResult, Error>) -> Void)?

struct MailViewModifier: ViewModifier {
    @Binding var message: ComposeMailData?
    let onDismiss: (() -> Void)?
    let mailSendResult: MailSendResult
    
    init(
        message: Binding<ComposeMailData?>,
        onDismiss: (() -> Void)? = nil,
        mailSendResult: MailSendResult
    ) {
        
        _message = message
        self.onDismiss = onDismiss
        self.mailSendResult = mailSendResult
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $message) {
                onDismiss?()
            } content: { message in
                if MailView.canSendMail {
                    MailView(data: message) {
                        (result: Result<MFMailComposeResult, Error>) in

                        mailSendResult?(result)
                    }
                } else {
                    NavigationStack {
                        ContentUnavailableView("Mail is not configured!", systemImage: "exclamationmark.triangle.fill", description: Text("Cannot send mail - please check that the Mail application is setup with an email account and try again."))
                            .toolbar {
                                ToolbarItem(
                                    placement: .cancellationAction) {
                                    
                                        Button("Cancel") {
                                        self.onDismiss?()
                                        self.message = nil
                                    }
                                }
                            }
                    }
                }
            }
    }
}


extension View {
    public func mailPresentation(
        message: Binding<ComposeMailData?>,
        onDismiss: (() -> Void)? = nil,
        mailSendResult: ((Result<MFMailComposeResult, Error>) -> Void)?
    ) -> some View {
        
        modifier(
            MailViewModifier(message: message,
                                  onDismiss: onDismiss,
                                  mailSendResult: mailSendResult)
        )
    }
}


/// MailView is the backing UIViewControllerRepresentable that presents the MFMailComposeViewController.
/// Only works if the user has an email address setup, which is a possible .failure case.
struct MailView: UIViewControllerRepresentable {
    let data: ComposeMailData
    let callback: MailSendResult
    
    init(data: ComposeMailData, callback: MailSendResult) {
        self.data = data
        self.callback = callback
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(data: data, callback: callback)
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MailView>
    ) -> MFMailComposeViewController {
        
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(data.subject)
        vc.setToRecipients(data.recipients)
        vc.setMessageBody(data.message, isHTML: false)
        
        data.attachments?.forEach {
          vc.addAttachmentData($0.data,
                               mimeType: $0.mimeType,
                               fileName: $0.fileName)
        }
        
        vc.accessibilityElementDidLoseFocus()
       
        return vc
    }

    /* no-op */
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {
    }
    
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        // NOTE: Dismiss is handled by the parent view --
        // avoiding @Environment(\.dismiss) as much as is possible.
        // (had bugs in previous iOS releases)
        let data: ComposeMailData?
        let callback: MailSendResult

        init(data: ComposeMailData?,
             callback: MailSendResult) {

            self.data = data
            self.callback = callback
        }
    

      func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
      ) {
        if let error = error {
          callback?(.failure(error))
        } else {
          callback?(.success(result))
        }
      }
    }
}

#endif // canImport(MessageUI) && canImport(UIKit)
