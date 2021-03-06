#include <UIKit/UIKit.h>
#include <MessageUI/MessageUI.h>

#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>

#include "iosmail.h"

@interface IOSMailDelegate : NSObject <MFMailComposeViewControllerDelegate>

@end

@implementation IOSMailDelegate

- (void) mailComposeController:(MFMailComposeViewController *)__attribute__((unused))controller
           didFinishWithResult:(MFMailComposeResult)__attribute__((unused))result
                         error:(NSError *)__attribute__((unused))error
{
    NSLog(@"mailComposeController didFinishWithResult");
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end

IOSMail::IOSMail(QObject* parent)
    : QObject(parent)
    , m_delegate([[IOSMailDelegate alloc] init])
{
}

// this way we CAN add attachments
void IOSMail::sendDb()
{
    //--------------------- basic check for mail possibility

    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    //--------------------- prepare mail view controller

    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:m_delegate];
    [mailController setToRecipients:[NSArray arrayWithObjects:@"example@gmail.com", nil]];
    [mailController setSubject:@"DB dump"];
    [mailController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //--------------------- add attachments
    
    NSArray *db = @[@"firstDb", @"secondDb", @"thirdDb"];
    BOOL withAttachment = FALSE;
    for (NSString* dbName in db) {
        NSString* dbPath = [[NSBundle mainBundle] pathForResource:dbName ofType:@"sqlite"];
        NSData* db = [NSData dataWithContentsOfFile:dbPath];
        if (!db) {
            continue;
        }
        [mailController addAttachmentData:db mimeType:@"application/x-sqlite3" fileName:dbName];
        withAttachment = TRUE;
    }
    if (withAttachment) {
        [mailController setMessageBody:@"Dear developer! Here is your DB dump :)." isHTML:YES];
    } else {
        [mailController setMessageBody:@"Dear developer! Tryed to send you DB dump, but didnt find one :(." isHTML:YES];
    }
    
    //--------------------- show mail view
    
    UIViewController* mainController = [[(__bridge UIView *)reinterpret_cast<void *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", QGuiApplication::focusWindow())) window] rootViewController];
    [mainController presentViewController:mailController animated:YES completion:^{
        NSLog(@"presentViewController completion");
    }];
}

// this way we CAN NOT add attachments
void IOSMail::contactUs()
{
    NSString* scheme = @"mailto";
    NSString* recipient = @"example@gmail.com";
    NSString* subject = [@"For Dear Support Team" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString* start = [@"Dear Support Team!" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL* mailUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@?subject=%@&body=%@", scheme, recipient, subject, start]];
    if ([[UIApplication sharedApplication] canOpenURL:mailUrl]) {
        [[UIApplication sharedApplication] openURL:mailUrl options:@{} completionHandler:nil];
    }
}
