#include "sqlitemanager.h"

#include <QDate>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

Sqlitemanager::Sqlitemanager(QObject *parent)
    : SQLmanager(parent)
{
}

bool Sqlitemanager::addContact(const QString& name, const QString& phone,
                       const QDate& birthDate, const QString& email) {
    QSqlQuery query;
    query.prepare("INSERT OR IGNORE INTO contacts (name, phone, birthdate, email) "
                  "VALUES (:name, :phone, :birthdate, :email)");
    query.bindValue(":name", name);
    query.bindValue(":phone", phone);
    query.bindValue(":birthdate", birthDate);
    query.bindValue(":email", email);
    if (!query.exec()) {
        qDebug() << "Failed to insert contact:" << query.lastError().text();
        return false;
    }
    return true;
}

bool Sqlitemanager::setupDB() {
    QSqlDatabase contactsDB = QSqlDatabase::addDatabase("QSQLITE");
    contactsDB.setDatabaseName("my_database.db");
    if (!contactsDB.open()) {
        qDebug() << "Error: " << contactsDB.lastError().text();
        return false;
    }
    createTable();
    return true;
}
