#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "storagecontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    StorageController storageController;
    engine.rootContext()->setContextProperty("storageControllerProperty", &storageController);
    engine.load(QUrl::fromLocalFile(":/Main.qml"));

    return app.exec();
}
