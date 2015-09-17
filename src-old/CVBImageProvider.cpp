#include "CVBImageProvider.h"
#include <QDebug>

CVBImageProvider::CVBImageProvider(ImageType type): QQuickImageProvider(type)
{
}

QImage CVBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return QImage(imageFolder+id);
}

QPixmap CVBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    qDebug()<<imageFolder+id;
    QPixmap result= QPixmap(imageFolder+id);

    if (result.isNull()){
        if (requestedSize.width()/((float)requestedSize.height())>1.5)
            result=QPixmap("://no_image_double.png");
        else
           result=QPixmap("://no_image.png");
    }

    return result;
}