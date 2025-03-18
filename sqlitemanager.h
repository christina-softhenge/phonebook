#ifndef SQLITEMANAGER_H
#define SQLITEMANAGER_H
#include "sqlmanager.h"

class Sqlitemanager : public SQLmanager
{
public:
    Sqlitemanager(QObject *parent = nullptr);
    virtual bool addContact(const QString& name, const QString& phone,
                           const QDate& birthDate, const QString& email) override;
    virtual bool setupDB(const QString& password) override;
    virtual bool setPassword(const QString& password) override;
    QString generateSalt(int length);
    QString hashPassword(const QString& password, const QString& salt);
    bool validatePassword(const QString& password);
};

#endif // SQLITEMANAGER_H
