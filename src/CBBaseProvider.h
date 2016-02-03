#ifndef CBBASEPROVIDER_H
#define CBBASEPROVIDER_H

#include <QObject>
#include <QtSql>
#include "CBNode.h"
#include "CBImageProvider.h"
#include "CBAttachmentsProvider.h"
#include "CBTranslator.h"

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

    Q_PROPERTY(QString baseTitle MEMBER m_baseTitle CONSTANT)
    Q_PROPERTY(CBAttachmentsProvider *attachmentsProvider MEMBER attachmentsProvider CONSTANT)

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
    Q_INVOKABLE QString listFormPath(CBNode *node);
    Q_INVOKABLE QString fullFormPath(CBNode *node);


    CBAttachmentsProvider *attachmentsProvider;
    CBImageProvider *imageProvider;

    //! path to about page for qml
    Q_INVOKABLE QString getAbout(){
        return "file:///" + rootPath + "about.html";
    }

    CBTranslator translator;


private:
    QString rootPath; //< root folder
    QString m_baseTitle;
    QString startTable;
    QSqlDatabase db;
    QMap<QString,CBNode*> nodeMap;//< Map which contains all node and uses for gwtting it by name

    void idWasSelected(const QString &id); //<when we set some record as selected, we need find attachments for it

signals:
    void readyToWork();
};

#endif // CBBASEPROVIDER_H
