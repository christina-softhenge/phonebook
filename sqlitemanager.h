#ifndef SQLITEMANAGER_H
#define SQLITEMANAGER_H
#include "sqlmanager.h"

class Sqlitemanager : public SQLmanager
{
public:
    Sqlitemanager(QObject *parent = nullptr);
    virtual QStringList addContact(const QString& name, const QString& phone,
                           const QDate& birthDate, const QString& email) override;
    void setupDB() override;
};

#endif // SQLITEMANAGER_H
