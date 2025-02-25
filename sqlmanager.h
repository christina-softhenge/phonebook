#ifndef SQLMANAGER_H
#define SQLMANAGER_H

#include <QObject>

class SQLmanager : public QObject
{
    Q_OBJECT
public:
    enum DatabaseType {
        MySQL = 0,
        SQLite = 1
    };
    explicit SQLmanager(QObject *parent = nullptr);
    void setDBType(int type);
    bool validateCSV(const QString& filePath);
    void importFromCSV(const QString& filePath);
    QStringList addContact(const QString& name,const QString& phone,const QDate& birthDate,const QString& email);
    QStringList addContactToMySql(const QString& name,const QString& phone,const QDate& birthDate,const QString& email);
    QStringList addContactToSqlite(const QString& name,const QString& phone,const QDate& birthDate,const QString& email);
    void editContact(const QString& key, const QStringList& editedContact);
    QVector<QStringList> filterWithKey(const QString& key);
    QVector<QStringList> getData();
    void removeRow(const QString& name);

private:
    DatabaseType dbType;
    void setupDB();
    void setupMYSQLDB();
    void setupSQLiteDB();
    void createTable();
};

#endif // SQLMANAGER_H
