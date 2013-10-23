#ifndef CVBSQLNODE_H
#define CVBSQLNODE_H

#include <QObject>
#include <QtSql>
#include <QString>
#include "CVBSqlRelationalTableModel.h"

struct CVBSqlNode{
    CVBSqlNode();
    QString tableName;
    CVBSqlRelationalTableModel *model;//модель-ссылка на таблицу
    QVector <QString> rowParamNames;
    QMap<QString, QString> childNodes;//идентификаторы узлов, на которые можно перейти от текущего и поле, по которому они связаны
    int defaultSortColumn;
    QString mainChild;//FIXME вопрос нужен ли он
    QString listFormName;
    QString fullFormName;
    QVariantMap delegates;

    QStringList *listViewFields;

    QVariant getListViewFields();
};

#endif // CVBSQLNODE_H
