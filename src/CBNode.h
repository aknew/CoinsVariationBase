#ifndef CBNODE_H
#define CBNODE_H

#include <QObject>

#include "CBSqlRelationalTableModel.h"


class CBNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant fullFormFields MEMBER fullFormFields FINAL)
    Q_PROPERTY(QVariant listViewFields MEMBER listViewFields FINAL)
    Q_PROPERTY(QString tableName MEMBER tableName FINAL)
    Q_PROPERTY(QStringList nextLevelList READ getNextLevelList  FINAL)
    Q_PROPERTY(QVariantMap selectedItem READ selectedItem)
    Q_PROPERTY(QAbstractItemModel* listModel READ listModel FINAL)

public:
    explicit CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent = 0);


    QString tableName;

    QString listFormName(); //< name of list form qml file for saving and loading
    QString fullFormName(); //< name of full form qml file for saving and loading


    QVariant listViewFields; //< describe which fields and how should be shown in list form
    QVariant fullFormFields; //< describe which fields and how should be shown in full form

protected:

    CBSqlRelationalTableModel *model;//< real table or view
    CBSqlRelationalTableModel *_listModel;//< presentation view
    QMap<QString, QString> childNodes;//< list of nodes where we can go from current

    QAbstractItemModel* listModel();

    QStringList getNextLevelList(){
        return childNodes.keys();
    }

    QVariantMap selectedItem(){
        return model->selectedItem();
    }


};

#endif // CBNODE_H
