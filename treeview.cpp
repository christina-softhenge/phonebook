#include "treeview.h"
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QFile>
#include <QDir>
#include <QDate>

TreeView::TreeView(QObject *parent)
    : QObject(parent)
    , m_standardModel(new QStandardItemModel(this))
    , m_rootNode(m_standardModel->invisibleRootItem())
    , m_watcher(new QFileSystemWatcher(this))
{
    QSqlDatabase contactsDB = QSqlDatabase::addDatabase("QMYSQL");
    contactsDB.setHostName("localhost");
    contactsDB.setPort(3306);
    contactsDB.setUserName("root");
    contactsDB.setPassword("softhenge306");
    contactsDB.setDatabaseName("my_database");
    if (!contactsDB.open()) {
        qDebug() << "Error: " << contactsDB.lastError().text();
        return;
    }

    QSqlQuery query;
    if (!query.exec("CREATE DATABASE IF NOT EXISTS my_database")) {
        qDebug() << "Failed to create database:" << query.lastError().text();
    } else {
        qDebug() << "Database created successfully!";
    }

    QString createTableQuery = R"(
                CREATE TABLE IF NOT EXISTS contacts (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL UNIQUE,
                    phone VARCHAR(20) NOT NULL,
                    birthdate DATE NOT NULL,
                    email VARCHAR(255) UNIQUE
                )
            )";

    if (!query.exec(createTableQuery)) {
        qDebug() << "Failed to create table:" << query.lastError().text();
    } else {
        qDebug() << "Table 'contacts' created successfully!";
    }
    getDataFromFile();
}

TreeView::~TreeView()
{ }

Q_INVOKABLE void TreeView::addContact(const QString& name,const QString& phone,const QString& birthDate,const QString& email) {
    QStringList dateParts = birthDate.split('/');
    QDate birthdate(dateParts[2].toInt(),dateParts[1].toInt(),dateParts[0].toInt());
    QSqlQuery query;
    query.prepare("INSERT IGNORE INTO contacts (name, phone, birthdate, email) "
                  "VALUES (:name, :phone, :birthdate, :email)");
    query.bindValue(":name", name);
    query.bindValue(":phone", phone);
    query.bindValue(":birthdate", birthdate);
    query.bindValue(":email", email);
    if (!query.exec()) {
        qDebug() << "Failed to insert contact:" << query.lastError().text();
    } else {
        qDebug() << "Contact added successfully!";
        QStandardItem* item = new QStandardItem(name);

        auto row = prepareRow(phone, birthdate.toString("dd-MM-yyyy"), email);

        m_rootNode->appendRow(item);
        item->appendColumn(row);
        emit modelChanged();
    }
}

void TreeView::getDataFromFile()
{
    m_rootNode->removeRows(0, m_rootNode->rowCount());

    QSqlQuery query;
    if (!query.exec("SELECT name, phone, birthdate, email "
                    "FROM contacts")) {
        qDebug() << "Failed to retrieve contacts:" << query.lastError().text();
    } else {
        while(query.next()) {
            QString name = query.value("name").toString();
            qDebug() << name;
            QString phone = query.value("phone").toString();
            QString birthdate = query.value("birthdate").toString();
            QString email = query.value("email").toString();

            QStandardItem* item = new QStandardItem(name);

            auto row = prepareRow(phone, birthdate, email);

            m_rootNode->appendRow(item);
            item->appendColumn(row);
        }
    }
}

QList<QStandardItem *> TreeView::prepareRow(const QString &first, const QString &second, const QString &third) const
{
    return {new QStandardItem(first), new QStandardItem(second), new QStandardItem(third)};
}


void TreeView::onDoubleClick(const QModelIndex &index)
{
    QString name = m_standardModel->data(index).toString();
    m_standardModel->removeRow(index.row());
    QSqlQuery query;
    query.prepare("DELETE FROM contacts WHERE name = :name");
    query.bindValue(":name",name);
    if (!query.exec()) {
        qDebug() << "Failed to delete contact:" << query.lastError().text();
    } else {
        qDebug() << "Contact deleted successfully!";
    }
    emit modelChanged();
}
