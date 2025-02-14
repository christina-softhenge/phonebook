#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "treeview.h"

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
    TreeView treeView;
    engine.rootContext()->setContextProperty("treeViewProperty", &treeView);
    engine.load(QUrl::fromLocalFile("/home/kristina/Qt_projects/phonebook/Main.qml"));

    return app.exec();
}
