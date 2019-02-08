#pragma once

#include <QObject>

Q_FORWARD_DECLARE_OBJC_CLASS(IOSMailDelegate);
//Q_FORWARD_DECLARE_OBJC_CLASS(MFMailComposeViewController);

class IOSMail : public QObject
{
    Q_OBJECT

public:
    explicit IOSMail(QObject* parent = nullptr);

    Q_INVOKABLE void sendDb();
    Q_INVOKABLE void contactUs();

private:
    IOSMailDelegate* m_delegate;
//    __strong MFMailComposeViewController* m_controller;
};
