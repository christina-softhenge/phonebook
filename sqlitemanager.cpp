#include "sqlitemanager.h"

#include <QDate>
#include<QSettings>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

Sqlitemanager::Sqlitemanager(QObject *parent)
    : SQLmanager(parent)
{
}

bool Sqlitemanager::addContact(const QString& name, const QString& phone,
                               const QDate& birthDate, const QString& email) {
    QSqlQuery query(m_db);
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

bool Sqlitemanager::setupDB(const QString& password) {
    QString defaultConnectionName = "qt_sql_default_connection";
    {
        QSqlDatabase existingDB = QSqlDatabase::database(defaultConnectionName, false);
        if (existingDB.isValid()) {
            existingDB.close();
            QSqlDatabase::removeDatabase(defaultConnectionName);
        }
    }

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("my_database.db");

    if (!m_db.open()) {
        qDebug() << "Error: " << m_db.lastError().text();
        return false;
    }

    if (!password.isEmpty()) {
        if (!validatePassword(password)) {
            qDebug() << "Invalid password provided";
            m_db.close();
            return false;
        }

        QSettings settings;
        settings.setValue("database/password", password);
        qDebug() << "Password stored in settings";
    }

    createTable(m_db);
    return true;
}

void Sqlitemanager::setPassword(const QString& password) {
    if (password.isEmpty()) {
        qDebug() << "Cannot set empty password";
        return;
    }

    QSettings settings;
    settings.setValue("database/password", password);
    qDebug() << "Password set successfully";
}

bool Sqlitemanager::validatePassword(const QString& password) {
    QSettings settings;
    QString storedPassword = settings.value("database/password").toString();

    if (storedPassword.isEmpty()) {
        return true;
    }

    return (password == storedPassword);
}
