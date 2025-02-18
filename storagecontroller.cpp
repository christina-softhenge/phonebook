#include "storagecontroller.h"
#include "sqlmanager.h"

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QDate>

StorageController::StorageController(QObject *parent)
    : QObject(parent)
    , m_standardModel(new QStandardItemModel(this))
    , m_rootNode(m_standardModel->invisibleRootItem())
    , m_SQLmanager(new SQLmanager())
{
    getDataFromDB();
}

StorageController::~StorageController()
{ }

Q_INVOKABLE void StorageController::addContact(const QString& name, const QString& phone, const QString& birthDate, const QString& email) {
    QStringList dateParts = birthDate.split('-');
    QDate birthdate(dateParts[0].toInt(), dateParts[1].toInt(), dateParts[2].toInt());

    QStringList list = m_SQLmanager->addContact(name, phone, birthdate, email);
    QStandardItem* item = new QStandardItem(list[0]);
    auto row = prepareRow(list[1], list[2], list[3]);
    m_rootNode->appendRow(item);
    item->appendColumn(row);
}

Q_INVOKABLE void StorageController::removeRow(int row, int column) {
    QModelIndex index = m_standardModel->index(row,column);
    onDoubleClick(index);
};

Q_INVOKABLE QStringList StorageController::getRow(int row, int column) {
    QModelIndex nameIndex = m_standardModel->index(row,column);
    QModelIndex phoneIndex = m_standardModel->index(0,0,nameIndex);
    QModelIndex dateIndex = m_standardModel->index(1,0,nameIndex);
    QModelIndex emailIndex = m_standardModel->index(2,0,nameIndex);

    QString name = m_standardModel->data(nameIndex).toString();
    QString phone = m_standardModel->data(phoneIndex).toString();
    QString date = m_standardModel->data(dateIndex).toString();
    QString email = m_standardModel->data(emailIndex).toString();

    return {name, phone, date, email};
}

Q_INVOKABLE void StorageController::editRow(const QString& key, const QStringList& changedRow) {
    m_SQLmanager->editContact(key, changedRow);
    getDataFromDB();
}

Q_INVOKABLE void StorageController::filterWithKey(const QString& key) {
    m_rootNode->removeRows(0, m_rootNode->rowCount());
    QVector<QStringList> filteredContacts = m_SQLmanager->filterWithKey(key);
    for (const QStringList& contactList : filteredContacts) {
        QStandardItem* item = new QStandardItem(contactList[0]);
        auto row = prepareRow(contactList[1], contactList[2], contactList[3]);
        m_standardModel->appendRow(item);
        item->appendColumn(row);
    }
}

void StorageController::getDataFromDB()
{
    m_rootNode->removeRows(0, m_rootNode->rowCount());
    QVector<QStringList> contactsVec = m_SQLmanager->getData();
    for (const QStringList& contactList : contactsVec) {
        QStandardItem* item = new QStandardItem(contactList[0]);
        auto row = prepareRow(contactList[1], contactList[2], contactList[3]);
        m_standardModel->appendRow(item);
        item->appendColumn(row);
    }
}

QList<QStandardItem *> StorageController::prepareRow(const QString &first, const QString &second, const QString &third) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third)};
}


void StorageController::onDoubleClick(const QModelIndex &index)
{
    QString name = m_standardModel->data(index).toString();
    m_standardModel->removeRow(index.row());
    m_SQLmanager->removeRow(name);
}
