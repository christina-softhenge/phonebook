#ifndef SQLMANAGER_H
#define SQLMANAGER_H

#include <QObject>

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
    virtual bool setupDB() = 0;

protected:
    void createTable();
};

#endif // SQLMANAGER_H
