#ifndef CBNODE_H
#define CBNODE_H

#include <QObject>

#include "CBSqlRelationalTableModel.h"


class CBNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant fullFormFields MEMBER fullFormFields CONSTANT)
    Q_PROPERTY(QVariant listViewFields MEMBER listViewFields CONSTANT)
    Q_PROPERTY(QString tableName MEMBER tableName CONSTANT)
    Q_PROPERTY(QStringList nextLevelList READ getNextLevelList CONSTANT)
    Q_PROPERTY(QVariantMap selectedItem READ selectedItem)
    Q_PROPERTY(QObject* listModel READ listModel NOTIFY dataChanged)
    Q_PROPERTY(bool usesUUIDs MEMBER usesUUIDs CONSTANT)
    Q_PROPERTY(bool useFullForm MEMBER useFullForm CONSTANT)
    Q_PROPERTY(bool useListForm MEMBER useListForm CONSTANT)
    Q_PROPERTY(QObject* filterList MEMBER filterList)

public:
    explicit CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent = 0);

    QObject *filterList = NULL; //< Uses for save listModel between filter dialog showing
    QString tableName;

    Q_INVOKABLE QString listFormName(); //< name of list form qml file for saving and loading
    Q_INVOKABLE QString fullFormName(); //< name of full form qml file for saving and loading


    QVariant listViewFields; //< describe which fields and how should be shown in list form
    QVariant fullFormFields; //< describe which fields and how should be shown in full form

    Q_INVOKABLE void selectItemWithIndex(int index); //< Uses for set selecteditem from qml

    QPair<QString,QString> filterForChildNode(const QString& childNodeName);

    void setLevelFilter(const QPair<QString,QString> &filter); //< filtering only record related to previous level
    Q_INVOKABLE void addFilter(const QString &filterString); //< add any other filters, uses for selection from related record
    Q_INVOKABLE void dropFilter(); //< drop all filters excapt level

    Q_INVOKABLE QStringList listFromQuery(QString query);

    Q_INVOKABLE void prepareToNewItem();
    Q_INVOKABLE void applyChanges(QVariantMap changedItem);
    Q_INVOKABLE void dropChanges();
    Q_INVOKABLE void deleteSelectedItem();

    /** \brief: clone current selected item as new item
     *  If node has UUID's id, new item will have it's own. Need use applyChanges();
     *  to save new item
    */
    Q_INVOKABLE void cloneItem();

    /**
      \brief UUID generating flag
      Reason - usually we use UUID as table primary key, but some table
      no need to do this. Usually this tables are affiliated like references list
    */
    bool usesUUIDs = true;

    bool useFullForm = false;
    bool useListForm = false;


signals:
    void idWasSelected(QString id);

    /** \brief means data was changed and qml should redraw table.
     * this signal is emited only if we use listModel, reason - if we just use standart model - all changes
     *  will be emited by model, but if we use separate lit model for list representation these signals will not
     * be accepted by qml (and actually, we have to force run listModel update)
     */
    void dataChanged();

protected:

    bool insertingNewRow = false;
    QSqlDatabase &db;

    CBSqlRelationalTableModel *model;//< real table or view
    CBSqlRelationalTableModel *_listModel;//< presentation view
    QMap<QString, QString> childNodes;//< list of nodes where we can go from current

    QObject* listModel();

    QString filter;
    QPair<QString,QString> levelFilter;

    QStringList getNextLevelList(){
        return childNodes.keys();
    }

    QVariantMap selectedItem(){
        return model->selectedItem();
    }

    void applyFilters();

};

#endif // CBNODE_H
