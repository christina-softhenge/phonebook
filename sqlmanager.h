#ifndef SQLMANAGER_H
#define SQLMANAGER_H

#include <QObject>

class SQLmanager : public QObject
{
    Q_OBJECT
public:
    explicit SQLmanager(QObject *parent = nullptr);
    QStringList addContact(const QString& name,const QString& phone,const QDate& birthDate,const QString& email);
    void editContact(const QString& key, const QStringList& editedContact);
    QVector<QStringList> filterWithKey(const QString& key);
    QVector<QStringList> getData();
    void removeRow(const QString& name);
private:
    void setupDB();
    void createTable();
signals:
};

#endif // SQLMANAGER_H
