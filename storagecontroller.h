#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QStandardItemModel>
#include <QFileSystemWatcher>
#include <QFileDialog>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

class SQLmanager;

class StorageController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* model READ getModel)
public:
    StorageController(QObject *parent = nullptr);
    ~StorageController();

    Q_INVOKABLE void addContact(const QString& name, const QString& phone, const QString& birthDate, const QString& email);
    Q_INVOKABLE void removeRow(int row, int column);
    Q_INVOKABLE QStringList getRow(int row, int column);
    Q_INVOKABLE void editRow(const QString& key, const QStringList& changedRow);
    Q_INVOKABLE void filterWithKey(const QString& key);
    Q_INVOKABLE QAbstractItemModel* getModel() const { return m_standardModel; }
private:
    void getDataFromDB();
    QList<QStandardItem *> prepareRow(const QString &first, const QString &second, const QString &third) const;
    //slots
    void onDoubleClick(const QModelIndex &index);

private:
    QStandardItemModel *m_standardModel;
    QStandardItem *m_rootNode;
    SQLmanager *m_SQLmanager;
};

#endif // MAINWINDOW_H
