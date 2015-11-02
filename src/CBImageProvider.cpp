#include "CBImageProvider.h"
#include <QDebug>
#include <QFile>
#include <QCryptographicHash>

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
    Q_UNUSED(requestedSize)

    //FIXME: need conver to jpg or use not only it
    qDebug()<<imageFolder+id+".jpg";
    QPixmap result= QPixmap(imageFolder+id+".jpg");

    if (result.isNull()){
        result=QPixmap("://no_image.png");
    }

    return result;
}

QString CBImageProvider::saveImage(QByteArray attach){

    QString md5=QCryptographicHash::hash(attach,QCryptographicHash::Md5).toHex();

    QString str=imageFolder + md5 + ".jpg";
    QFile file(str);

    if (!file.open(QIODevice::WriteOnly)) return "NULL";
    file.write(attach);
    return md5;
}
