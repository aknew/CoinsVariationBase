#ifndef CBUTILSTESTSET_H
#define CBUTILSTESTSET_H

#include <QObject>

class CBUTilsTestSet : public QObject
{
    Q_OBJECT
public:
    explicit CBUTilsTestSet(QObject *parent = 0):QObject(parent){}

private slots:
    void stringDifference();
};

#endif // CBUTILSTESTSET_H
