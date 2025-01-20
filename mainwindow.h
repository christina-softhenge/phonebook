#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTreeView>
#include <QStandardItemModel>
#include <QFileSystemWatcher>
#include <QFileDialog>

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
    QTreeView *m_treeView;
    QStandardItemModel *m_standardModel;
    QStandardItem *m_rootNode;
    QFileSystemWatcher *m_watcher;
    QFileDialog *m_fileDialog;
    QString m_filePath;
};

#endif // MAINWINDOW_H
