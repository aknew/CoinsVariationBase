#ifndef CBFIELDDIFFERENCE_H
#define CBFIELDDIFFERENCE_H

#include <QObject>

/**
 * @brief The CBFieldDifference class needs to show records difference in qml
 */
class CBFieldDifference : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER _name CONSTANT)
    Q_PROPERTY(QString highlightedFirst MEMBER _highlightedFirst CONSTANT)
    Q_PROPERTY(QString highlightedSecond MEMBER _highlightedSecond CONSTANT)
    Q_PROPERTY(bool isEqual MEMBER _isEqual CONSTANT)
public:
    explicit CBFieldDifference(QObject *parent = 0);
    QString _name;
    QString _highlightedFirst;
    QString _highlightedSecond;
    bool _isEqual = false;
};

#endif // CBFIELDDIFFERENCE_H
