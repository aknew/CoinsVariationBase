#ifndef DELEGATEDTABLEVIEW_H
#define DELEGATEDTABLEVIEW_H

#include <QTableView>
#include "CVBBaseProvider.h"

class DelegatedTableView : public QTableView
{
    Q_OBJECT
    CVBBaseProvider *_baseProvider;

public:
    explicit DelegatedTableView(QWidget *parent = 0);
    void setBaseProvider(CVBBaseProvider *baseProvider);
    
signals:
    
public slots:

    void showNextLevelMenu(const QPoint &pos);
    
};

#endif // DELEGATEDTABLEVIEW_H
