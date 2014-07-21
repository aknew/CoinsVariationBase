#ifndef COINSBASEPROVIDER_H
#define COINSBASEPROVIDER_H

#include <QObject>
#include <QtSql>
#include <QString>
#include "CVBSqlNode.h"
#include "comboboxdescription.h"

class CVBBaseProvider : public QObject
{
    Q_OBJECT
    QSqlDatabase db;
    QString startTable;
    QStack<CVBSqlNode*> nodeStack;//как мы дошли до текущей
    QMap<QString,CVBSqlNode*> nodeMap;//словарь-список всех таблиц
    QMap <QString,QString> ids;//уже использованные идентификаторы
    QMap <QString, ComboBoxDescription> comboBoxes;
    void parse();

public:
    explicit CVBBaseProvider(QString pathPath="base.sqlite" ,QObject *parent = 0);
    ~CVBBaseProvider();


    QString basePath;
    QStringList systemTables;

    void pressedButton(int index);
    void startLevel();
    CVBSqlNode *currentNode();
    QStringList buttonIDs();

    //работа с картинками - захочу потом убрать их из базы, просто заменю код внутри функций
    QString idForAttach(QByteArray attach);
    QByteArray attachForId(QString id);
    QStringList listForID(const QString &name);
    void addForeignKeyToMap(QVariantMap &map);
    void deleteCurrentRow();
    QAbstractItemModel *getModelWithName(const QString& name);
    CVBSqlNode *nodeWithName(const QString& name);

signals:
    //TODO: check that all this signals are realy needs
    void newTableWidget();
    void removeCurrentWidget();
    void getError(QString description);

public slots:
    void previousLevel();

    void loadSystemTables(const QString &name);

};

#endif // COINSBASEPROVIDER_H
