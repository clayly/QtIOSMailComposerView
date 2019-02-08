#include <QtQuick>
#include "iosmail.h"

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
//    app.primaryScreen()->setOrientationUpdateMask(Qt::PortraitOrientation | Qt::LandscapeOrientation);

    qmlRegisterType<IOSMail>("IOSMail", 1, 0, "IOSMail");

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.loadUrl(QUrl("qrc:/main.qml"));
    QQuickWindow* window = qobject_cast<QQuickWindow*>(component.create());
    window->show();

    return app.exec();
}


