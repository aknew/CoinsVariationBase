#include "CVBImageProvider.h"
#include <QDebug>

CVBImageProvider::CVBImageProvider(ImageType type): QDeclarativeImageProvider(type)
{
}

QImage CVBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    return QImage(imageFolder+id);
}

QPixmap CVBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    qDebug()<<imageFolder+id;
    QPixmap result= QPixmap(imageFolder+id);

    if (result.isNull()){
        if (requestedSize.width()/((float)requestedSize.height())>1.5)
            result=QPixmap("://resources/no_image_double.png");
        else
           result=QPixmap("://resources/no_image.png");
    }

    return result;
}
