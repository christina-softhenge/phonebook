#ifndef MYSQLMANAGER_H
#define MYSQLMANAGER_H
#include "sqlmanager.h"

class MySqlmanager : public SQLmanager
{
public:
    explicit MySqlmanager(QObject *parent = nullptr);
    QStringList addContact(const QString& name, const QString& phone,
                           const QDate& birthDate, const QString& email) override;
    void setupDB() override;
};

#endif // MYSQLMANAGER_H
