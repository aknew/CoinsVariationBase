#ifndef CBBASEPROVIDER_H
#define CBBASEPROVIDER_H

#include <QObject>
#include <QtSql>

class CBBaseProvider : public QObject
/*! \brief implement base logic - reading/writing data, loading/saving images, transitions between tables, etc
 * It actually should have abstact parrent, but I have only one kind of database now and don't think that will be use
 * more kinds in the nearest future
*/
{
    Q_OBJECT

    Q_PROPERTY(QString baseTitle MEMBER m_baseTitle FINAL)

public:
    explicit CBBaseProvider(QObject *parent = 0):QObject(parent){}
    void startWithPath(const QString &path);//< start base interaction with path

private:
    QString rootPath; //< root folder
    QString m_baseTitle;
    QSqlDatabase db;

signals:
    void readyToWork();

};

#endif // CBBASEPROVIDER_H
