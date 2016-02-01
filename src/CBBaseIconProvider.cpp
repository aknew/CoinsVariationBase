#include "CBBaseIconProvider.h"

#include "CBSettings.h"

CBBaseIconProvider::CBBaseIconProvider(ImageType type): QQuickImageProvider(type)
{

}

QImage CBBaseIconProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return QImage(CBSettings::settingsInstance()->recentPathByName(id)+"/icon.png");
}

QPixmap CBBaseIconProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    QString fullFilePath = CBSettings::settingsInstance()->recentPathByName(id)+"icon.png";
    QPixmap result= QPixmap(fullFilePath);

    if (result.isNull()){
        result=QPixmap("://no_image.png");
    }

    return result;
}

