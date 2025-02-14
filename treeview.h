#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTreeView>
#include <QStandardItemModel>
#include <QFileSystemWatcher>
#include <QFileDialog>

class TreeView : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* model READ getModel NOTIFY modelChanged)
public:
    TreeView(QObject *parent = nullptr);
    ~TreeView();

    void getDataFromFile(const QString &path);

    Q_INVOKABLE void setPath(QString path) {
        if (path.startsWith("file://")) {
            path.remove(0, 7);
        }
        m_filePath = path;
        getDataFromFile(m_filePath);

        m_watcher->addPath(m_filePath);
        connect(m_watcher,&QFileSystemWatcher::fileChanged, this, &TreeView::onFileChanged);
        emit modelChanged();
    }
    Q_INVOKABLE QAbstractItemModel* getModel() const { return m_standardModel; }
    Q_INVOKABLE void addContact(const QString& name,const QString& phone,const QString& birthDate,const QString& email);
    Q_INVOKABLE void onItemDoubleClicked(int row, int column) {
        QModelIndex index = m_standardModel->index(row,column);
        onDoubleClick(index);
        emit modelChanged();
    };
private:
    QList<QStandardItem *> prepareRow(const QString &first, const QString &second, const QString &third) const;

    //slots
    void onFileChanged(const QString &path);
    void onDoubleClick(const QModelIndex &index);

signals:
    void modelChanged();
private:
    QStandardItemModel *m_standardModel;
    QStandardItem *m_rootNode;
    QFileSystemWatcher *m_watcher;
    QString m_filePath;
};

#endif // MAINWINDOW_H
