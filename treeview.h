#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTreeView>
#include <QStandardItemModel>
#include <QFileSystemWatcher>
#include <QFileDialog>

class TreeView : public QWidget
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* model READ getModel NOTIFY modelChanged)
public:
    TreeView(QWidget *parent = nullptr);
    ~TreeView();

    void getDataFromFile(const QString &path);
    void initModel();

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
    QTreeView *m_treeView;
    QStandardItemModel *m_standardModel;
    QStandardItem *m_rootNode;
    QFileSystemWatcher *m_watcher;
    QFileDialog *m_fileDialog;
    QString m_filePath;
};

#endif // MAINWINDOW_H
