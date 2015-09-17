#ifndef CBSqlRelationalTableModel_H
#define CBSqlRelationalTableModel_H

#include <QAbstractListModel>
#include <QSqlRelationalTableModel>

class CBSqlRelationalTableModel : public QSqlRelationalTableModel
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
    CBSqlRelationalTableModel(QObject *parent, QSqlDatabase _db):QSqlRelationalTableModel(parent,_db){this->setEditStrategy(QSqlTableModel::OnRowChange);}
    void applyRoles();
    void removeCurrentItem();
    void sortByColumn(const QString &name);
    int selectedRow;
    QString selectedItemId();

virtual QHash<int, QByteArray> roleNames() const{return roles;}


private:
    int count;
    QHash<int, QByteArray> roles;
};

#endif // CBSqlRelationalTableModel_H
