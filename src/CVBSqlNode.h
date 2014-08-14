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
    Q_PROPERTY(QString name MEMBER tableName)
    Q_PROPERTY(QStringList nextLevelList READ getNextLevelList)
    Q_PROPERTY(QVariantMap selectedItem READ selectedItem)
    Q_PROPERTY(QList<QObject*> subNodes READ getSubnodes)

protected:
    QMap<QString, QString> m_subNodes;//идентификаторы зависимых узлов и поле, по которому они связаны

public:
    explicit CVBSqlNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent);

    QString tableName;
    CVBSqlRelationalTableModel *model;//модель-ссылка на таблицу
    CVBSqlRelationalTableModel *listModel;//модель-ссылка на таблицу для показа в виде списка
    QVector <QString> rowParamNames;
    QMap<QString, QString> childNodes;//идентификаторы узлов, на которые можно перейти от текущего и поле, по которому они связаны
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

     QList<QObject* > getSubnodes();
};

#endif // CVBSQLNODE_H
