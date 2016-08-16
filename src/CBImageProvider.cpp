#include "CBImageProvider.h"
#include <QFile>
#include <QFileIconProvider>

CBImageProvider::CBImageProvider(ImageType type):
    QQuickImageProvider(type)
{

}

QImage CBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    QPixmap px = requestPixmap(id,size,requestedSize);
    return px.toImage();
}

QPixmap CBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
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

    if (requestedSize.width()>0 && requestedSize.height()>0){
        result = result.scaled(requestedSize,Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    return result;
}
