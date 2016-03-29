#include "CBImageProvider.h"
#include <QDebug>
#include <QFile>
#include <QFileIconProvider>

CBImageProvider::CBImageProvider(ImageType type):
    QQuickImageProvider(type)
{

}

QImage CBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return QImage(attachmentsProvider->_basePath+id);
}

QPixmap CBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    // unquoting {}
    QString _id = id;
    _id.replace("%7B","{");
    _id.replace("%7D","}");
    QString fullFilePath = attachmentsProvider->_basePath+_id;
    QPixmap result= QPixmap(fullFilePath);

    if (result.isNull()){
        QFileIconProvider provider;
        QIcon icon = provider.icon(fullFilePath);
        if (icon.isNull()){ // FIXME: not null, but icon is wrong
            result=QPixmap("://no_image.png");
        }
        else{
            result = icon.pixmap(90,90);
        }
    }

    return result;
}
