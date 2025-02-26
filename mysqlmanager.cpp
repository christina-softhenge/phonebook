#include "mysqlmanager.h"

#include <QDate>
#include <QApplication>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

MySqlmanager::MySqlmanager(QObject *parent)
    : SQLmanager(parent)
{
}

QStringList MySqlmanager::addContact(const QString& name, const QString& phone,
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
    } else {
        return QStringList { name, phone, birthDate.toString("dd-MM-yyyy"), email };
    }
    return {};
}

void MySqlmanager::setupDB() {
    QSqlDatabase contactsDB = QSqlDatabase::addDatabase("QMYSQL");
    contactsDB.setHostName("localhost");
    contactsDB.setPort(3306);
    contactsDB.setUserName("root");
    contactsDB.setPassword("softhenge306");
    contactsDB.setDatabaseName("my_database");

    if (!contactsDB.open()) {
        qDebug() << "Error: " << contactsDB.lastError().text();
        QApplication::quit();
        return;
    }

    QSqlQuery query;
    if (!query.exec("CREATE DATABASE IF NOT EXISTS my_database")) {
        qDebug() << "Failed to create database:" << query.lastError().text();
    }
    query.exec("Delete From contacts");
}
