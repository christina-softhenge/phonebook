#include "mysqlmanager.h"

#include <QDate>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

MySqlmanager::MySqlmanager(QObject *parent)
    : SQLmanager(parent)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");

    if (!db.isValid()) {
        qDebug() << "Failed to load MySQL driver!";
    }
    createUser("username", "password");
}

bool MySqlmanager::createUser(const QString& username, const QString& password)
{
    QSqlDatabase adminDB = QSqlDatabase::addDatabase("QMYSQL", "admin_connection");
    adminDB.setHostName("localhost");
    adminDB.setPort(3306);
    adminDB.setUserName("root");
    adminDB.setPassword("your_new_password");

    if (!adminDB.open()) {
        qDebug() << "Failed to connect as admin:" << adminDB.lastError().text();
        return false;
    }

    QSqlQuery query(adminDB);

    QString createUserSQL = QString("CREATE USER IF NOT EXISTS '%1'@'localhost' IDENTIFIED BY '%2'")
                                .arg(username)
                                .arg(password);

    if (!query.exec(createUserSQL)) {
        qDebug() << "Failed to create user:" << query.lastError().text();
        adminDB.close();
        return false;
    }

    QString grantSQL = QString("GRANT ALL PRIVILEGES ON my_database.* TO '%1'@'localhost'")
                           .arg(username);

    if (!query.exec(grantSQL)) {
        qDebug() << "Failed to grant privileges:" << query.lastError().text();
        adminDB.close();
        return false;
    }

    if (!query.exec("FLUSH PRIVILEGES")) {
        qDebug() << "Failed to flush privileges:" << query.lastError().text();
        adminDB.close();
        return false;
    }
    adminDB.close();
    return true;
}

bool MySqlmanager::addContact(const QString& name, const QString& phone,
                              const QDate& birthDate, const QString& email) {
    QSqlQuery query(m_db);
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


bool MySqlmanager::setupDB(const QString& password)
{
    QSqlDatabase tempDB = QSqlDatabase::addDatabase("QMYSQL", "admin_connection");
    tempDB.setHostName("localhost");
    tempDB.setPort(3306);
    tempDB.setUserName("username");
    tempDB.setPassword(password);

    if (!tempDB.open()) {
        qDebug() << "Error: " << tempDB.lastError().text();
        return false;
    }

    QSqlQuery query(tempDB);
    if (!query.exec("CREATE DATABASE IF NOT EXISTS my_database")) {
        qDebug() << "Error: Could not create database" << query.lastError();
        return false;
    }

    tempDB.setDatabaseName("my_database");

    if (!tempDB.open()) {
        return false;
    }
    createTable(tempDB);
    return true;
}



void MySqlmanager::setPassword(const QString& password) {
    QSqlQuery query(m_db);
    query.prepare("ALTER USER 'username'@'localhost' IDENTIFIED BY :pass");
    query.bindValue(":pass", password);
    if (!query.exec()) {
        qDebug() << "Error updating password:" << query.lastError().text();
    } else {
        qDebug() << "Password updated successfully!";
    }
}


