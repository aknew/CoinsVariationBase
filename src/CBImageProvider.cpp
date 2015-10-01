#include "CBImageProvider.h"
#include <QDebug>

CBImageProvider::CBImageProvider(ImageType type): QQuickImageProvider(type)
{

}

QImage CBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return QImage(imageFolder+id);
}

QPixmap CBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)

    //FIXME: need conver to jpg or use not only it
    qDebug()<<imageFolder+id+".jpg";
    QPixmap result= QPixmap(imageFolder+id+".jpg");

    return result;
}
