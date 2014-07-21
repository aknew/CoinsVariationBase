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

public:
    explicit CVBSqlNode(const QJsonObject &obj, QSqlDatabase &db);

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
};

#endif // CVBSQLNODE_H
