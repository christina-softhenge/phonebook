#include "treeview.h"

#include <QFile>
#include <QDir>

TreeView::TreeView(QWidget *parent)
    : QWidget(parent)
    , m_treeView(new QTreeView(this))
    , m_standardModel(new QStandardItemModel(this))
    , m_rootNode(m_standardModel->invisibleRootItem())
    , m_watcher(new QFileSystemWatcher(this))
    , m_fileDialog(new QFileDialog(this))
    , m_filePath(m_fileDialog->getOpenFileName(this, "Select Data Source File", "", "Text Files (*.txt);;All Files (*)"))
{
    resize(600,500);

    initModel();
    getDataFromFile(m_filePath);

    m_watcher->addPath(m_filePath);
    connect(m_watcher,&QFileSystemWatcher::fileChanged, this, &TreeView::onFileChanged);
    connect(m_treeView, &QTreeView::doubleClicked, this, &TreeView::onDoubleClick);
    for (int col = 0; col < m_standardModel->columnCount(); ++col) {
        m_treeView->resizeColumnToContents(col);
    }
    emit modelChanged();
}

TreeView::~TreeView()
{ }

Q_INVOKABLE void TreeView::addContact(const QString& name,const QString& phone,const QString& birthDate,const QString& email) {
    qDebug() << name << "\n";
    QStandardItem* item = new QStandardItem(name);

    auto row = prepareRow(phone, birthDate, email);

    m_rootNode->appendRow(item);
    item->appendColumn(row);
    emit modelChanged();
}

void TreeView::initModel()
{
    m_treeView->setModel(m_standardModel);
    m_treeView->setHeaderHidden(false);
}

void TreeView::getDataFromFile(const QString& path)
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
        item->appendColumn(row);
    }
    m_treeView->expandAll();
    file.close();
}


QList<QStandardItem *> TreeView::prepareRow(const QString &first, const QString &second, const QString &third) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third)};
}

void TreeView::onFileChanged(const QString &path)
{
    getDataFromFile(path);
    if (m_watcher->files().empty()) {
        m_watcher->addPath(path);
    }
}

void TreeView::onDoubleClick(const QModelIndex &index)
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
            QStandardItem* dateItem = nameItem->child(1,0);
            if (!phoneItem) {
                qDebug() << "Valodik";
            }
            QStandardItem* emailItem = nameItem->child(2,0);
            out << nameItem->text() << ", " << phoneItem->text() << ", " << dateItem->text() << ", " << emailItem->text() << '\n';
        } else {
            qDebug() << "empty";
        }
    }
    qDebug() << "Valodik2";
    emit modelChanged();
    file.close();
}
