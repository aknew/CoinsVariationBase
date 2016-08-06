#include "CBBaseIconProvider.h"
#include "CBSettings.h"

CBBaseIconProvider::CBBaseIconProvider(ImageType type): QQuickImageProvider(type)
{

}

QImage CBBaseIconProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    QPixmap px = requestPixmap(id,size,requestedSize);
    return px.toImage();
}

QPixmap CBBaseIconProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    QString fullFilePath = CBSettings::settingsInstance()->recentPathByName(id)+"icon.png";
    QPixmap result= QPixmap(fullFilePath);


    if (result.isNull()){
        //TODO: need use some constants instead string
        if (id == QObject::tr("Open new base")){
                result=QPixmap("://add_database.png");
        }
        else{
            result=QPixmap("://database.png");
        }
    }

    return result;
}

