#include "mainwindow.h"

#include <QFile>
#include <QTimer>
#include <QTextStream>
#include <QDebug>
#include <QTreeView>
#include <QStandardItemModel>
#include <QStandardItem>
#include <QFileSystemWatcher>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , filePath("/home/kristina/Qt_projects/phonebook_mv/phonebook.txt")
    , treeView(new QTreeView(this))
    , standardModel(new QStandardItemModel(this))
    , rootNode(standardModel->invisibleRootItem())
    , watcher(new QFileSystemWatcher(this))
{
    setCentralWidget(treeView);
    resize(600,500);

    initModel();

    getDataFromFile(filePath);

    watcher->addPath(filePath);
    connect(watcher,&QFileSystemWatcher::fileChanged, this, &MainWindow::onFileChanged);
    connect(treeView, &QTreeView::doubleClicked, this, &MainWindow::onDoubleClick);
    for (int col = 0; col < standardModel->columnCount(); ++col) {
        treeView->resizeColumnToContents(col);
    }
}

MainWindow::~MainWindow() {
}

void MainWindow::initModel() {
    standardModel->setColumnCount(3);
    standardModel->setHorizontalHeaderLabels({"Phone", "Date of birth", "Email"});
    treeView->setModel(standardModel);
    treeView->expandAll();
    treeView->setHeaderHidden(false);
}

void MainWindow::getDataFromFile(const QString& path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file";
        return;
    }

    QTextStream fileStream(&file);
    rootNode->removeRows(0, rootNode->rowCount());
    while (!fileStream.atEnd()) {
        QString line = fileStream.readLine();
        QStringList list = line.split(QRegularExpression("[,\\s]+"));
        QStandardItem* item = new QStandardItem(list[0]);
        auto row = prepareRow(list[1], list[2], list[3]);
        rootNode->appendRow(item);
        item->appendRow(row);
    }
    file.close();
    treeView->expandAll();
}


QList<QStandardItem *> MainWindow::prepareRow(const QString &first, const QString &second, const QString &third) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third)};
}

void MainWindow::onFileChanged(const QString &path) {
    getDataFromFile(path);
    if (watcher->files().empty()) {
        watcher->addPath(path);
    }
}

void MainWindow::onDoubleClick(const QModelIndex &index) {
    standardModel->removeRow(index.row());
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file";
        return;
    }
    QTextStream out(&file);
    for (int row = 0; row < standardModel->rowCount(); ++row) {
        QStandardItem* nameItem = standardModel->item(row);
        if (nameItem) {
            QStandardItem* phoneItem = nameItem->child(0,0);
            QStandardItem* dateItem = nameItem->child(0,1);
            QStandardItem* emailItem = nameItem->child(0,2);
            out << nameItem->text() << ", " << phoneItem->text() << ", " << dateItem->text() << ", " << emailItem->text() << '\n';
        } else {
            qDebug() << "empty";
        }
    }
    file.close();
}
