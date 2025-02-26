#include "storagecontroller.h"
#include "sqlitemanager.h"
#include "mysqlmanager.h"

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QDate>

StorageController::StorageController(QObject *parent)
    : QObject(parent)
    , m_standardModel(new QStandardItemModel(this))
    , m_SQLmanager(nullptr)
{
}

StorageController::~StorageController()
{ }

Q_INVOKABLE void StorageController::setDBType(int type) {
    if (m_SQLmanager != nullptr) {
        delete m_SQLmanager;
    }
    if (type == 0) {
        m_SQLmanager = new MySqlmanager();
    } else if (type == 1) {
        m_SQLmanager = new Sqlitemanager();
    }
    m_SQLmanager->setupDB();
    importFromCSV();
}

Q_INVOKABLE void StorageController::setPath(const QString& path) {
    filePath = path;
    if (filePath.startsWith("file://")) {
        filePath.remove(0, 7);
    }
}

Q_INVOKABLE void StorageController::addContact(const QString& name, const QString& phone,
                                               const QString& birthDate, const QString& email) {
    QStringList dateParts = birthDate.split('-');
    QDate birthdate(dateParts[0].toInt(), dateParts[1].toInt(), dateParts[2].toInt());

    QStringList list = m_SQLmanager->addContact(name, phone, birthdate, email);
    getDataFromDB();
}

Q_INVOKABLE void StorageController::removeRow(int row, int column) {
    QModelIndex index = m_standardModel->index(row,column);
    QString name = m_standardModel->data(index).toString();
    m_SQLmanager->removeRow(name);
    getDataFromDB();
};

Q_INVOKABLE QStringList StorageController::getRow(int row) {
    QModelIndex nameIndex = m_standardModel->index(row,0);
    QModelIndex phoneIndex = m_standardModel->index(row,1);
    QModelIndex dateIndex = m_standardModel->index(row,2);
    QModelIndex emailIndex = m_standardModel->index(row,3);

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
    m_standardModel->clear();
    QVector<QStringList> filteredContacts = m_SQLmanager->filterWithKey(key);
    for (const QStringList& contactList : filteredContacts) {
        auto row = prepareRow(contactList[0], contactList[1], contactList[2], contactList[3]);
        m_standardModel->appendRow(row);
    }
}

void StorageController::getDataFromDB()
{
    m_standardModel->clear();
    QVector<QStringList> contactsVec = m_SQLmanager->getData();
    for (const QStringList& contactList : contactsVec) {
        auto row = prepareRow(contactList[0], contactList[1], contactList[2], contactList[3]);
        m_standardModel->appendRow(row);
    }
}

void StorageController::importFromCSV()
{
    m_SQLmanager->importFromCSV(filePath);
    getDataFromDB();
}

QList<QStandardItem *> StorageController::prepareRow(const QString &first, const QString &second,
                                                     const QString &third, const QString &fourth) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third), new QStandardItem(fourth)};
}
