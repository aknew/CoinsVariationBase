#ifndef CBITEMDIFFERENCE_H
#define CBITEMDIFFERENCE_H

#include <QObject>
/**
 * @brief The CBItemDifference class contains all information which is needed to show items' difference
 */
class CBItemDifference : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> allFieldsModel MEMBER allFieldsModel CONSTANT)
    Q_PROPERTY(QList<QObject*> diffFieldsModel MEMBER diffFieldsModel CONSTANT)
    Q_PROPERTY(QString id1 MEMBER id1 CONSTANT)
    Q_PROPERTY(QString id2 MEMBER id2 CONSTANT)

public:
    explicit CBItemDifference(QObject *parent = 0);

    QList<QObject*> allFieldsModel; /// all fields from full form with highlightet difference
    QList<QObject*> diffFieldsModel; /// only realy different fields
    QString id1; /// first item identifier, needs to show images, also will be used to merging items
    QString id2; /// second item identifier, needs to show images, also will be used to merging items

};

#endif // CBITEMDIFFERENCE_H
