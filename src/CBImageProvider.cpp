#include "CBImageProvider.h"
#include <QFile>
#include <QFileIconProvider>
#include <QDir>
#include <QDebug>

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

    QString cachedImage = attachmentsProvider->_basePath + QString("__cache/%1x%2/").arg(requestedSize.width()).arg(requestedSize.height()) +  _id;

    QPixmap result= QPixmap(cachedImage);

    if (!result.isNull()){
        return result;
    }

    result = QPixmap(fullFilePath);

    if (result.isNull()){
        QFile file(fullFilePath);
#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID)
        /* HOTFIX:
         iOs crashes here with message
         global/qglobal.cpp(3070): ASSERT: "!"No style available without QApplication!"" in file kernel/qapplication.cpp, line 1064
         Maybe there is better solution that not run this code in iOS, but right now I haven't enough time to search it for so minor feature
         */
        if(file.exists()){
            qDebug()<< id;
            QFileIconProvider provider;
            QIcon icon = provider.icon(fullFilePath);
            result = icon.pixmap(90,90);
        }
#endif
        if (result.isNull()){
            cachedImage = attachmentsProvider->_basePath + QString("__cache/%1x%2/").arg(requestedSize.width()).arg(requestedSize.height()) +"no_image.png";
            result= QPixmap(cachedImage);
            if (result.isNull()){
                result=QPixmap("://no_image.png");
            }
        }
    }

    if (requestedSize.width()>0 && requestedSize.height()>0){
        result = result.scaled(requestedSize,Qt::KeepAspectRatio, Qt::SmoothTransformation);
        QString dir = cachedImage.section("/",0,-2);
        if (!QDir(dir).exists()){
            QDir().mkpath(dir);
        }
        bool flag = result.save(cachedImage);
        if (!flag){
            qDebug()<< cachedImage;

        }
    }

    return result;
}
