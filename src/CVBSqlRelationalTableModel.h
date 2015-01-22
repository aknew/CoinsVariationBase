#ifndef CVBSqlRelationalTableModel_H
#define CVBSqlRelationalTableModel_H

#include <QAbstractListModel>
#include <QSqlRelationalTableModel>

class CVBSqlRelationalTableModel : public QSqlRelationalTableModel
{
    // модель для qml
    Q_OBJECT
    Q_PROPERTY( int count READ rowCount() NOTIFY countChanged())
    Q_PROPERTY( QVariant  fieldList MEMBER fieldList)

signals:
    void countChanged();

public:
    Q_INVOKABLE virtual QVariant data(const QModelIndex &index, int role) const;
    QVariantMap selectedItem();
    QVariant fieldList;
    void setSelectedItem(const QVariantMap &map);
    CVBSqlRelationalTableModel(QObject *parent, QSqlDatabase _db):QSqlRelationalTableModel(parent,_db){this->setEditStrategy(QSqlTableModel::OnRowChange);}
    void applyRoles();
    void removeCurrentItem();
    int selectedRow;

virtual QHash<int, QByteArray> roleNames() const{return roles;}


private:
    int count;
    QHash<int, QByteArray> roles;
};

#endif // CVBSqlRelationalTableModel_H
