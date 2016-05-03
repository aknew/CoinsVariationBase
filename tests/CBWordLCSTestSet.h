#ifndef CBUTILSTESTSET_H
#define CBUTILSTESTSET_H

#include <QObject>

class CBWordLCSTestSet : public QObject
{
    Q_OBJECT
public:
    explicit CBWordLCSTestSet(QObject *parent = 0):QObject(parent){}

private slots:
    void stringDifference();
};

#endif // CBUTILSTESTSET_H
