#include "treeview.h"

#include <QFile>
#include <QDir>

TreeView::TreeView(QObject *parent)
    : QObject(parent)
    , m_standardModel(new QStandardItemModel(this))
    , m_rootNode(m_standardModel->invisibleRootItem())
    , m_watcher(new QFileSystemWatcher(this))
{
}

TreeView::~TreeView()
{ }

Q_INVOKABLE void TreeView::addContact(const QString& name,const QString& phone,const QString& birthDate,const QString& email) {
    QStandardItem* item = new QStandardItem(name);

    auto row = prepareRow(phone, birthDate, email);

    m_rootNode->appendRow(item);
    item->appendColumn(row);
    emit modelChanged();
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
            QStandardItem* emailItem = nameItem->child(2,0);
            out << nameItem->text() << ", " << phoneItem->text() << ", " << dateItem->text() << ", " << emailItem->text() << '\n';
        } else {
            qDebug() << "empty";
        }
    }
    emit modelChanged();
    file.close();
}
