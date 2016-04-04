#include "CBImageProvider.h"
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
        result = icon.pixmap(90,90);
        if (result.isNull()){
            result=QPixmap("://no_image.png");
        }
    }

    return result;
}
