#include "sqlmanager.h"
#include <QApplication>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QDate>
#include <QFile>

SQLmanager::SQLmanager(QObject *parent)
    : QObject{parent} {
}

void SQLmanager::setDBType(int type) {
    dbType = static_cast<DatabaseType>(type);
    setupDB();
}

bool SQLmanager::validateCSV(const QString& filePath) {
    QFile csvFile(filePath);
    if (!csvFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "ERROR: unable to open csv file";
        return false;
    }
    QTextStream in(&csvFile);
    if (in.atEnd()) {
        qDebug() << "ERROR: csv file is empty";
        return false;
    }
    int columnCount = -1;
    while (!in.atEnd()) {
        QStringList line = in.readLine().split(',');
        if (columnCount == -1)
            columnCount = line.count();
        if (line.count() != columnCount) {
            qDebug () << "ERROR: invalid csv";
            return false;
        }
    }
    return true;
}

void SQLmanager::importFromCSV(const QString& filePath) {
    if (!validateCSV(filePath)) {
        return;
    }
    QFile csvFile(filePath);
    if (!csvFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "ERROR: unable to open csv file";
        return;
    }
    QTextStream in(&csvFile);
    bool firstLine = true;

    QSqlQuery query;
    query.exec("DELETE "
               "FROM contacts");

    while (!in.atEnd()) {
        QString line = in.readLine();
        if (firstLine) {
            firstLine = false;
            continue;
        }

        QStringList fields = line.split(",");

        QString name = fields[0].trimmed();
        QString phone = fields[1].trimmed();
        QString date = fields[2].trimmed();
        QString email = fields[3].trimmed();

        QDate birthdate = QDate::fromString(date, "yyyy-MM-dd");
        query.prepare("INSERT INTO contacts (name, phone, birthdate, email) "
                      "VALUES (?, ?, ?, ?)");
        query.addBindValue(name);
        query.addBindValue(phone);
        query.addBindValue(birthdate);
        query.addBindValue(email);

        if (!query.exec()) {
            qDebug() << "Error inserting data:" << query.lastError().text();
        }
    }

    csvFile.close();
}

QStringList SQLmanager::addContact(const QString& name, const QString& phone,
                                          const QDate& birthDate, const QString& email) {
    if (dbType == DatabaseType::MySQL) {
        return addContactToMySql(name, phone, birthDate, email);
    } else {
        return addContactToSqlite(name, phone, birthDate, email);
    }
}

QStringList SQLmanager::addContactToMySql(const QString& name, const QString& phone,
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

QStringList SQLmanager::addContactToSqlite(const QString& name, const QString& phone,
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
    } else {
        return QStringList { name, phone, birthDate.toString("dd-MM-yyyy"), email };
    }
    return {};
}

void SQLmanager::editContact(const QString& key, const QStringList& changedRow) {
    QStringList dateParts = changedRow[2].split('-');
    QDate birthdate(dateParts[0].toInt(), dateParts[1].toInt(), dateParts[2].toInt());

    QSqlQuery query;
    query.prepare(R"(
        UPDATE contacts
        SET name = :newName,
            phone = :newPhone,
            birthdate = :newDate,
            email = :newEmail
        WHERE name LIKE :key
        )");
    query.bindValue(":key","%" + key + "%");
    query.bindValue(":newName", changedRow[0]);
    query.bindValue(":newPhone", changedRow[1]);
    query.bindValue(":newDate", birthdate);
    query.bindValue(":newEmail", changedRow[3]);
    if (!query.exec()) {
        qDebug() << "Failed to edit contact:" << query.lastError().text();
    }
}

QVector<QStringList> SQLmanager::filterWithKey(const QString& key) {
    QSqlQuery query;
    query.prepare(R"(
        SELECT * FROM contacts
        WHERE name LIKE :key
        OR phone LIKE :key
        OR email LIKE :key
    )");

    QString likePattern = "%" + key + "%";
    query.bindValue(":key",likePattern);

    QVector<QStringList> filteredContacts;
    if (!query.exec()) {
        qDebug() << "Query execution failed:" << query.lastError().text();
    } else {
        while (query.next()) {
            QString name = query.value("name").toString();
            QString phone = query.value("phone").toString();
            QString birthdate = query.value("birthdate").toString();
            QString email = query.value("email").toString();
            QStringList contact {name,phone,birthdate,email};
            filteredContacts.push_back(contact);
        }
    }
    return filteredContacts;
}

QVector<QStringList> SQLmanager::getData() {
    QSqlQuery query;
    QVector<QStringList> contactsVec;
    if (!query.exec("SELECT name, phone, birthdate, email "
                    "FROM contacts")) {
        qDebug() << "Failed to retrieve contacts:" << query.lastError().text();
    } else {
        while(query.next()) {
            QString name = query.value("name").toString();
            QString phone = query.value("phone").toString();
            QString birthdate = query.value("birthdate").toString();
            QString email = query.value("email").toString();
            QStringList contact {name,phone,birthdate,email};
            contactsVec.push_back(contact);
        }
    }
    return contactsVec;
}

void SQLmanager::removeRow(const QString& name) {
    QSqlQuery query;
    query.prepare("DELETE FROM contacts WHERE name = :name");
    query.bindValue(":name",name);
    if (!query.exec()) {
        qDebug() << "Failed to delete contact:" << query.lastError().text();
    }
}

void SQLmanager::setupDB() {
    if (dbType == DatabaseType::MySQL) {
        setupMYSQLDB();
    } else {
        setupSQLiteDB();
    }
    createTable();
}

void SQLmanager::setupMYSQLDB() {
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

void SQLmanager::setupSQLiteDB() {
    QSqlDatabase contactsDB = QSqlDatabase::addDatabase("QSQLITE");
    contactsDB.setDatabaseName("my_database.db");
    if (!contactsDB.open()) {
        qDebug() << "Error: " << contactsDB.lastError().text();
        QApplication::quit();
        return;
    }
}

void SQLmanager::createTable() {
    QString createTableQuery = R"(
                CREATE TABLE IF NOT EXISTS contacts (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL UNIQUE,
                    phone VARCHAR(20) NOT NULL,
                    birthdate DATE NOT NULL,
                    email VARCHAR(255) UNIQUE
                )
            )";
    QSqlQuery query;
    if (!query.exec(createTableQuery)) {
        qDebug() << "Failed to create table:" << query.lastError().text();
    }
}
