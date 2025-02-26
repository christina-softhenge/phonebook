#include "mysqlmanager.h"

#include <QDate>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

MySqlmanager::MySqlmanager(QObject *parent)
    : SQLmanager(parent)
{
}

bool MySqlmanager::addContact(const QString& name, const QString& phone,
                              const QDate& birthDate, const QString& email) {
    QSqlQuery query;
    query.prepare("INSERT IGNORE INTO contacts (name, phone, birthdate, email) "
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

bool MySqlmanager::setupDB() {
    QSqlDatabase contactsDB = QSqlDatabase::addDatabase("QMYSQL");
    contactsDB.setHostName("localhost");
    contactsDB.setPort(3306);
    contactsDB.setUserName("root");
    contactsDB.setPassword("softhenge306");
    contactsDB.setDatabaseName("my_database");

    if (!contactsDB.open()) {
        qDebug() << "Error: " << contactsDB.lastError().text();
        return false;
    }

    QSqlQuery query;
    if (!query.exec("CREATE DATABASE IF NOT EXISTS my_database")) {
        qDebug() << "Failed to create database:" << query.lastError().text();
        return false;
    }
    createTable();
    return true;
}
