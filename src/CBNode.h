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
    Q_PROPERTY(QObject* listModel READ listModel FINAL)

public:
    explicit CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent = 0);


    QString tableName;

    QString listFormName(); //< name of list form qml file for saving and loading
    QString fullFormName(); //< name of full form qml file for saving and loading


    QVariant listViewFields; //< describe which fields and how should be shown in list form
    QVariant fullFormFields; //< describe which fields and how should be shown in full form

    Q_INVOKABLE void selectItemWithIndex(int index){
        //* Uses for set selecteditem from qml
        model->selectedRow = index;
    }

    QString filteringStringForChildNode(const QString& childNodeName);

    void setLevelFilter(const QString &filterString); //< filtering only record related to previous level
    void addFilter(const QString &filterString); //< add any other filters, uses for selection from related record
    void dropFilters(); //< drop all filters excapt level

    Q_INVOKABLE QStringList listFromQuery(QString query);

protected:

    QSqlDatabase &db;

    CBSqlRelationalTableModel *model;//< real table or view
    CBSqlRelationalTableModel *_listModel;//< presentation view
    QMap<QString, QString> childNodes;//< list of nodes where we can go from current

    QObject* listModel();

    QStringList filters;
    QString levelFilter;

    QStringList getNextLevelList(){
        return childNodes.keys();
    }

    QVariantMap selectedItem(){
        return model->selectedItem();
    }

    void applyFilters();
};

#endif // CBNODE_H
