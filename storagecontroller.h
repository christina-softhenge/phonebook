#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QStandardItemModel>
#include <QFileSystemWatcher>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

class SQLmanager;

class StorageController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* model READ getModel NOTIFY modelChanged)
public:
    StorageController(QObject *parent = nullptr);
    ~StorageController();

    Q_INVOKABLE bool setDBType(int type);
    Q_INVOKABLE void setPath(const QString& path);
    Q_INVOKABLE bool addContact(const QString& name, const QString& phone, const QString& birthDate, const QString& email);
    Q_INVOKABLE void deleteRows(const QVariant &rows);
    Q_INVOKABLE QStringList getRow(int row);
    Q_INVOKABLE void editRow(const QString& key, const QStringList& changedRow);
    Q_INVOKABLE void filterWithKey(const QString& key);
    Q_INVOKABLE QAbstractItemModel* getModel() const { return m_standardModel; }

private:
    void removeRow(int row);
    void getDataFromDB();
    void importFromCSV();
    QList<QStandardItem *> prepareRow(const QString &first, const QString &second, const QString &third, const QString &fourth) const;
signals:
    void modelChanged();
private:
    QString filePath;
    QStandardItemModel *m_standardModel;
    SQLmanager *m_SQLmanager;
};

#endif // MAINWINDOW_H
