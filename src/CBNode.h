#ifndef CBNODE_H
#define CBNODE_H

#include <QObject>

#include "CBSqlRelationalTableModel.h"

class CBBaseProvider;
class CBItemDifference;

class CBNode : public QObject
{
    friend class CBBaseProvider;

    Q_OBJECT
    Q_PROPERTY(QVariant fullFormFields MEMBER fullFormFields CONSTANT)
    Q_PROPERTY(QVariant listViewFields MEMBER listViewFields CONSTANT)
    Q_PROPERTY(QString tableName MEMBER tableName CONSTANT)
    Q_PROPERTY(QStringList nextLevelList MEMBER _nextLevelList)
    Q_PROPERTY(QStringList predefinedFiltesList READ getPredefinedFiltesList CONSTANT)
    Q_PROPERTY(QVariantMap selectedItem READ selectedItem)
    Q_PROPERTY(QObject* listModel READ listModel NOTIFY dataChanged)
    Q_PROPERTY(bool usesUUIDs MEMBER usesUUIDs CONSTANT)
    Q_PROPERTY(bool useFullForm MEMBER useFullForm CONSTANT)
    Q_PROPERTY(bool useListForm MEMBER useListForm CONSTANT)
    Q_PROPERTY(QString filter READ getFilter WRITE setFilter)
    Q_PROPERTY(bool editable MEMBER editable CONSTANT) //<< needs to show/hide editing menu

public:
    QString tableName;

    Q_INVOKABLE QString listFormName(); //< name of list form qml file for saving and loading
    Q_INVOKABLE QString fullFormName(); //< name of full form qml file for saving and loading


    QVariant listViewFields; //< describe which fields and how should be shown in list form
    QVariant fullFormFields; //< describe which fields and how should be shown in full form

    Q_INVOKABLE void selectItemWithIndex(int index); //< Uses for set selecteditem from qml

    QPair<QString,QString> filterForChildNode(const QString& childNodeName);

    void setLevelFilter(const QPair<QString,QString> &filter); //< filtering only record related to previous level
    QString getFilter();
    Q_INVOKABLE void setFilter(const QString &filterString); //< add any other filters, uses for selection from related record
    Q_INVOKABLE void dropFilter(); //< drop all filters excapt level

    Q_INVOKABLE QStringList listFromQuery(QString query);

    Q_INVOKABLE void prepareToNewItem();
    Q_INVOKABLE void applyChanges(QVariantMap changedItem);
    Q_INVOKABLE void dropChanges();
    Q_INVOKABLE void deleteSelectedItem();

    Q_INVOKABLE void applyPredefinedFilter(const QString &f);

    /** \brief: clone current selected item as new item
     *  If node has UUID's id, new item will have it's own. Need use applyChanges();
     *  to save new item
    */
    Q_INVOKABLE void cloneItem();

    /** \brief return selected item (i.e. sql resord) as variant map
    * is used from qml, in future will be used for exporting record as json
    */
    QVariantMap selectedItem(){
        return m_listModel->selectedItem();
    }


    /** \brief create string which describe selected item
     * usually it is just concatineted listview fields from current node tables
     */
    QString selectedItemDescription();

    Q_INVOKABLE CBItemDifference *recordDifference(int index1, int index2);

    Q_INVOKABLE bool mergeRecords(QString src, QString dst, QVariantMap mergedItem, QString diff);

    Q_INVOKABLE void exportListToFile(const QString &path);

    QObject* listModel(){
        /*HOTFIX: invalid conversion from 'QObject*' to 'CBSqlRelationalTableModel*' [-fpermissive]
        * andIhave to use QObject* to push listModel to qml
        */
        return m_listModel;
    }

signals:
    void idWasSelected(QString id);

    /**
     * This signal is recieved by BaseController and baseController removes attachs and removes all related rows in subnodes
   */
    void currentItemWillBeRemoved();

    /** \brief means data was changed and qml should redraw table.
     * this signal is emited only if we use listModel, reason - if we just use standart model - all changes
     *  will be emited by model, but if we use separate lit model for list representation these signals will not
     * be accepted by qml (and actually, we have to force run listModel update)
     */
    void dataChanged();

private:
    /**
     * @brief CBNode Protected constructor. Only CBBaseProvider can create new node, all other should ask it to get node
     * @param obj
     * @param db
     * @param parent
     */
    explicit CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent = 0);

    bool insertingNewRow = false;
    QSqlDatabase &db;

    CBSqlRelationalTableModel *m_listModel;//< presentation view

    QMap<QString, QString> childNodes;//< list of nodes where we can go from current
    QMap<QString, QString> predefinedFiltes;//< predefined filters from struct.json

    QStringList getPredefinedFiltesList(){
         return predefinedFiltes.keys();
    }

    QString filter;
    QPair<QString,QString> levelFilter;

    QStringList _nextLevelList;

    void applyFilters();

    /**
     * @brief listForExport generate variant list which will be saved as json
     * this methods mostly needs for exporting subnodes
     * @param path - needs to copy attachments
     * @return
     */
    QVariantList listForExport(const QString &path);

    /**
     * @brief itemAtIndex
     * @param index - index of row in listView
     * @return record as variant map
     */
    QVariantMap itemAtIndex(int index);

    /**
      \brief UUID generating flag
      Reason - usually we use UUID as table primary key, but some table
      no need to do this. Usually this tables are affiliated like references list
    */
    bool usesUUIDs = true;

    bool useFullForm = false;
    bool useListForm = false;

    bool editable = true;

    bool containsSubnode(const QString &name){
        return _nextLevelList.contains(name);
    }

    QStringList fullFormFieldsInternal; //! uses when we compare two records

private:
    int findRowWithID(const QString &id);
};

#endif // CBNODE_H
