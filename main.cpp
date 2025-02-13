#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "treeview.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    TreeView treeView;
    engine.rootContext()->setContextProperty("treeViewProperty", &treeView);
    engine.load(QUrl::fromLocalFile("/home/kristina/Qt_projects/phonebook/main.qml"));

    return app.exec();
}
