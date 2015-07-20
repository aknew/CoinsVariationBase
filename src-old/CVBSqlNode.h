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
    Q_PROPERTY(QList<QObject*> subNodes MEMBER m_subNodes)
    Q_PROPERTY(bool hasImages MEMBER m_hasImages)
    Q_PROPERTY(bool hasNotes MEMBER m_hasNotes)

protected:
    QMap<QString, QString> m_subNodesParameters;//идентификаторы зависимых узлов и поле, по которому они связаны
    QPair<QString, QString> filterParam;

public:

    static const int kNewRowIndex = -1; //! specific constant, if node get it as selected row index it prepares for inserting new row

    explicit CVBSqlNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent);

    QString tableName;
    CVBSqlRelationalTableModel *model;//модель-ссылка на таблицу
    CVBSqlRelationalTableModel *listModel;//модель-ссылка на таблицу для показа в виде списка // TODO: this model is not used now
    QMap<QString, QString> childNodes;//идентификаторы узлов, на которые можно перейти от текущего и поле, по которому они связаны
    QString listFormName();
    QString fullFormName();

    QVariant fullFormFields;
    QVariant listViewFields;
    bool m_hasImages, m_hasNotes;

    Q_INVOKABLE QObject* getListModel();

    QStringList getNextLevelList(){
        return childNodes.keys();
    }

    QVariantMap selectedItem(){
        return model->selectedItem();
    }

    QList<QObject* > m_subNodes;
    void selectItemWithIndex(int index);
    void commitData();

    void setFilter(QPair<QString, QString> _filterParam);
};

#endif // CVBSQLNODE_H
