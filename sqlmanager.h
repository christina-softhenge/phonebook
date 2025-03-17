#ifndef SQLMANAGER_H
#define SQLMANAGER_H

#include <QObject>
#include <QSqlDatabase>

class SQLmanager : public QObject
{
    Q_OBJECT
public:
    explicit SQLmanager(QObject *parent = nullptr);
    bool validateCSV(const QString& filePath);
    void importFromCSV(const QString& filePath);
    virtual bool addContact(const QString& name,const QString& phone,const QDate& birthDate,const QString& email) = 0;
    void editContact(const QString& key, const QStringList& editedContact);
    QVector<QStringList> filterWithKey(const QString& key);
    QVector<QStringList> getData();
    void removeRow(const QString& email);
    virtual bool setupDB(const QString& password) = 0;
    virtual void setPassword(const QString& password) = 0;
protected:
    void createTable(QSqlDatabase &db);

protected:
    QSqlDatabase m_db;
};

#endif // SQLMANAGER_H
