#ifndef CBBASEPROVIDER_H
#define CBBASEPROVIDER_H

#include <QObject>
#include <QtSql>
#include "CBNode.h"
#include "CBImageProvider.h"

class CBBaseProvider : public QObject
/*! \brief implement base logic - reading/writing data, loading/saving images, transitions between tables, etc
 * It actually should have abstact parent, but I have only one kind of database now and don't think that will be use
 * more kinds in the nearest future
 *
 * Known limitations:
 *
 * each table has to contains primary key field called "id" and this field is used for navigation between nodes
*/
{
    Q_OBJECT

    Q_PROPERTY(QString baseTitle MEMBER m_baseTitle FINAL)
    Q_PROPERTY(QObject* images READ getImages())

public:
    explicit CBBaseProvider(QObject *parent = 0):QObject(parent){}
    ~CBBaseProvider();

    void startWithPath(const QString &path);//< start base interaction with path

    Q_INVOKABLE CBNode* getNode(const QString &name, CBNode * currentNode = NULL); //< returns node by name with preparing it (filtering by froeighn keys) and puting it to stack
    Q_INVOKABLE CBNode* getStartNode(){
        return getNode(startTable);
    }

    Q_INVOKABLE void saveListForm(const QString& qmlString, CBNode *node);
    Q_INVOKABLE void saveFullForm(const QString& qmlString, CBNode *node);


    CBImageProvider *imageProvider;
    QObject *getImages(){
        return m_imageModel;
    }
    Q_INVOKABLE QVariantMap imageFullInfo(int index){
        m_imageModel->selectedRow = index;
        return m_imageModel->selectedItem();
    }

    Q_INVOKABLE void saveImageInfo(QVariantMap imageInfo);

private:
    QString rootPath; //< root folder
    QString m_baseTitle;
    QString startTable;
    QSqlDatabase db;
    QMap<QString,CBNode*> nodeMap;//< Map which contains all node and uses for gwtting it by name


    CBSqlRelationalTableModel *m_imageModel; //< model for reading images list from base
    void idWasSelected(const QString &id); //<when we set some record as selected, we need find Images and Nodes for it

signals:
    void readyToWork();
};

#endif // CBBASEPROVIDER_H
