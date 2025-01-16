#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTreeView>
#include <QStandardItemModel>
#include <QFileSystemWatcher>

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    void getDataFromFile(const QString &path);
    void initModel();
private:
    QList<QStandardItem *> prepareRow(const QString &first, const QString &second, const QString &third) const;

    //slots
    void onFileChanged(const QString &path);
    void onDoubleClick(const QModelIndex &index);
private:
    QString filePath;
    QTreeView* treeView;
    QStandardItemModel* standardModel;
    QStandardItem *rootNode;
    QFileSystemWatcher* watcher;
};

#endif // MAINWINDOW_H
