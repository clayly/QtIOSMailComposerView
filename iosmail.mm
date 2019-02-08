#include <UIKit/UIKit.h>
#include <MessageUI/MessageUI.h>

#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>

#include "iosmail.h"

@interface IOSMailDelegate : NSObject <MFMailComposeViewControllerDelegate>
//@property (nonatomic) IOSMail* m_iosMail;
//@property (nonatomic, strong) IOSMail* m_iosMail;
@end

@interface IOSMailDelegate()
{
    IOSMail * m_iosMail;
//    @property (nonatomic, weak) IOSMail* m_iosMail;
}
@end

@implementation IOSMailDelegate

//- (id) initWithIOSMail:(IOSMail *)iosMail
//{
//    self = [super init];
//    if (self) {
//        m_iosMail = iosMail;
//    }
//    return self;
//}

//- (id) init
//{
//    self = [super init];
////    if (self) {
////        [self setM_iosMail:iosMail];
////    }
//    return self;
//}

- (void) mailComposeController:(MFMailComposeViewController *)__attribute__((unused))controller
           didFinishWithResult:(MFMailComposeResult)__attribute__((unused))result
                         error:(NSError *)__attribute__((unused))error
{
    NSLog(@"didFinishWithResult");
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    //[controller dismissViewControllerAnimated:YES completion:nil];
}

@end

//IOSMail::IOSMail(QQuickItem* parent)
IOSMail::IOSMail(QObject* parent)
//    : QQuickItem(parent)
//    : QQuickItem(nullptr)
    : QObject(parent)
//    , m_delegate([[IOSMailDelegate alloc] initWithIOSMail:this])
//    , m_delegate((__bridge __strong void *)reinterpret_cast<id>([[IOSMailDelegate alloc] initWithIOSMail:this]))
//    , m_controller((__bridge __strong void *)reinterpret_cast<id>([[MFMailComposeViewController alloc] init]))
    , m_delegate(nullptr)
{
}

void IOSMail::sendDb()
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    //--------------------- UIView
    
//    UIView *view = static_cast<UIView *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", window()));
//    UIView *view = static_cast<UIView *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", QGuiApplication::focusWindow()));
//    UIView* view = (__bridge UIView *)reinterpret_cast<void *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", QGuiApplication::focusWindow()));
//    UIView* view = (__bridge UIView *)reinterpret_cast<void *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", window()));
    
    //--------------------- UIViewController
    
//    UIViewController* qtCtrl = [[view window] rootViewController];
    UIViewController* qtCtrl = [[(__bridge UIView *)reinterpret_cast<void *>(QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", QGuiApplication::focusWindow())) window] rootViewController];
    
    //--------------------- MFMailComposeViewController
    
//    MFMailComposeViewController* mail = [[[MFMailComposeViewController alloc] init] autorelease]; // no-arc: quit-crash
    MFMailComposeViewController* mail = [[MFMailComposeViewController alloc] init]; // arc: quit-crash
//    MFMailComposeViewController* mail = (__bridge MFMailComposeViewController *)reinterpret_cast<void *>(m_controller);
//    m_controller = (__bridge void *)reinterpret_cast<MFMailComposeViewController *>(mail);
//    m_controller = mail;
    
    //--------------------- IOSMailDelegategit
    
//    IOSMailDelegate* delegate = [[IOSMailDelegate alloc] init];
//    m_delegate = (__bridge void *)reinterpret_cast<IOSMailDelegate *>(delegate);
//    m_delegate = delegate;
    m_delegate = [[IOSMailDelegate alloc] init];
    
    //--------------------- delegate setup
    
//    [mail setMailComposeDelegate:delegate];
    [mail setMailComposeDelegate:m_delegate];
//    [mail setMailComposeDelegate:[[IOSMailDelegate alloc] init]]; // arc: quit-crash
//    [(__bridge MFMailComposeViewController *)reinterpret_cast<void *>(m_controller) setMailComposeDelegate:[[IOSMailDelegate alloc] init]];
//    [mail setMailComposeDelegate:[[[IOSMailDelegate alloc] init] autorelease]];  // no-arc: quit-crash
//    [mail setMailComposeDelegate:id(m_delegate)]; // no-arc: ok
//    [mail setMailComposeDelegate:((__bridge __strong id)reinterpret_cast<void *>(m_delegate))]; // arc: enter-crash
    
    //--------------------- message prepare
    
    [mail setToRecipients:[NSArray arrayWithObjects:@"example@gmail.com", nil]];
    [mail setSubject:@"DB dump"];
    [mail setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    NSArray *db = @[@"firstDb", @"secondDb", @"thirdDb"];
    BOOL isThereAnyData = FALSE;
    for (id object in db) {
        NSString *path = [[NSBundle mainBundle] pathForResource:object ofType:@"sqlite"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (!data) {
            continue;
        }
        [mail addAttachmentData:data mimeType:@"application/x-sqlite3" fileName:path];
        isThereAnyData = TRUE;
    }
    if (isThereAnyData) {
        [mailController setMessageBody:@"Dear developer!\n Here is your DB dump :)." isHTML:YES];
    } else {
        [mailController setMessageBody:@"Dear developer!\n Tryed to send you DB dump, but didnt find one :(." isHTML:YES];
    }
    
    //--------------------- show mail
    
    [qtCtrl presentViewController:mail animated:YES completion:^{
        NSLog(@"presentViewController completion");
       // [mail dismissViewControllerAnimated:YES completion:nil];
    }];
}

void IOSMail::contactUs()
{
    NSString* schemeStr = @"mailto";
    NSString* toMailStr = @"support@biolink.tech";
    NSString* subjectStr = [@"For Dear Biolink Support Team" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString* startStr = [@"Dear Biolink Support Team!" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString* mailStr = [NSString stringWithFormat:@"%@:%@?subject=%@&body=%@", schemeStr, toMailStr, subjectStr, startStr];
    NSURL* mailUrl = [NSURL URLWithString:mailStr];
    if ([[UIApplication sharedApplication] canOpenURL:mailUrl]) {
        [[UIApplication sharedApplication] openURL:mailUrl options:@{} completionHandler:nil];
    }
}
