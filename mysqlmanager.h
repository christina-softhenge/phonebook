#ifndef MYSQLMANAGER_H
#define MYSQLMANAGER_H
#include "sqlmanager.h"

class MySqlmanager : public SQLmanager
{
public:
    explicit MySqlmanager(QObject *parent = nullptr);
    virtual bool addContact(const QString& name, const QString& phone,
                           const QDate& birthDate, const QString& email) override;
    virtual bool setupDB(const QString& password) override;
    virtual void setPassword(const QString& password) override;
    bool createUser(const QString& username, const QString& password);
};

#endif // MYSQLMANAGER_H
