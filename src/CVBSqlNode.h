#ifndef CVBSQLNODE_H
#define CVBSQLNODE_H

#include <QObject>
#include <QtSql>
#include <QString>
#include "CVBSqlRelationalTableModel.h"

class CVBSqlNode: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant fullFormFields MEMBER fullFormFields)
    Q_PROPERTY(QVariant listViewFields MEMBER listViewFields)
    Q_PROPERTY(QStringList nextLevelList READ getNextLevelList)
    Q_PROPERTY(QVariantMap selectedItem READ selectedItem)
    Q_PROPERTY(QStringList subNodes READ getSubnodes)

public:
    explicit CVBSqlNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent);

    QString tableName;
    CVBSqlRelationalTableModel *model;//модель-ссылка на таблицу
    CVBSqlRelationalTableModel *listModel;//модель-ссылка на таблицу для показа в виде списка
    QVector <QString> rowParamNames;
    QMap<QString, QString> childNodes;//идентификаторы узлов, на которые можно перейти от текущего и поле, по которому они связаны
    QMap<QString, QString> subNodes;//идентификаторы зависимых узлов и поле, по которому они связаны
    QString listFormName;
    QString fullFormName;

    QVariant fullFormFields;
    QVariant listViewFields;

    Q_INVOKABLE QObject* getListModel();

    QStringList getNextLevelList(){
        return childNodes.keys();
    }

    QVariantMap selectedItem(){
        return model->selectedItem();
    }

    QStringList getSubnodes(){
        return subNodes.keys();
    }
};

#endif // CVBSQLNODE_H
