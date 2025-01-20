#include "mainwindow.h"

#include <QFile>
#include <QDir>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , m_treeView(new QTreeView(this))
    , m_standardModel(new QStandardItemModel(this))
    , m_rootNode(m_standardModel->invisibleRootItem())
    , m_watcher(new QFileSystemWatcher(this))
    , m_fileDialog(new QFileDialog(this))
    , m_filePath(m_fileDialog->getOpenFileName(this, "Select Data Source File", "", "Text Files (*.txt);;All Files (*)"))
{
    setCentralWidget(m_treeView);
    resize(600,500);

    initModel();
    getDataFromFile(m_filePath);

    m_watcher->addPath(m_filePath);
    connect(m_watcher,&QFileSystemWatcher::fileChanged, this, &MainWindow::onFileChanged);
    connect(m_treeView, &QTreeView::doubleClicked, this, &MainWindow::onDoubleClick);
    for (int col = 0; col < m_standardModel->columnCount(); ++col) {
        m_treeView->resizeColumnToContents(col);
    }
}

MainWindow::~MainWindow()
{ }

void MainWindow::initModel()
{
    m_standardModel->setColumnCount(3);
    m_standardModel->setHorizontalHeaderLabels({"Phone", "Date of birth", "Email"});
    m_treeView->setModel(m_standardModel);
    m_treeView->setHeaderHidden(false);
}

void MainWindow::getDataFromFile(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file";
        return;
    }

    QTextStream fileStream(&file);
    m_rootNode->removeRows(0, m_rootNode->rowCount());
    while (!fileStream.atEnd()) {
        QString line = fileStream.readLine();
        QStringList list = line.split(QRegularExpression("[,\\s]+"));
        if (list.size() != 4) {
            throw std::length_error("List size is not appropriate");
        }
        QStandardItem* item = new QStandardItem(list[0]);
        auto row = prepareRow(list[1], list[2], list[3]);
        m_rootNode->appendRow(item);
        item->appendRow(row);
    }
    m_treeView->expandAll();
    file.close();
}


QList<QStandardItem *> MainWindow::prepareRow(const QString &first, const QString &second, const QString &third) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third)};
}

void MainWindow::onFileChanged(const QString &path)
{
    getDataFromFile(path);
    if (m_watcher->files().empty()) {
        m_watcher->addPath(path);
    }
}

void MainWindow::onDoubleClick(const QModelIndex &index)
{
    m_standardModel->removeRow(index.row());
    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file";
        return;
    }
    QTextStream out(&file);
    for (int row = 0; row < m_standardModel->rowCount(); ++row) {
        QStandardItem* nameItem = m_standardModel->item(row);
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
