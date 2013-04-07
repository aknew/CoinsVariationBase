#ifndef COMBOBOXDESCRIPTION_H
#define COMBOBOXDESCRIPTION_H

#include <QString>
#include <QVector>


struct ComboBoxDescription
{
    ComboBoxDescription();
    QString query;
    QVector<QString>params;

};

#endif // COMBOBOXDESCRIPTION_H
