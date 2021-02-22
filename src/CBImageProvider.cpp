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
    Q_UNUSED(requestedSize)
    // unquoting {}
    QString _id = id;
    _id.replace("%7B","{");
    _id.replace("%7D","}");
    QString fullFilePath = attachmentsProvider->_basePath+_id;

    QPixmap result= QPixmap(fullFilePath);

    if (!result.isNull()){
        return result;
    }

    result = QPixmap(fullFilePath);

    if (result.isNull()){
#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID)
        /* HOTFIX:
         iOs crashes here with message
         global/qglobal.cpp(3070): ASSERT: "!"No style available without QApplication!"" in file kernel/qapplication.cpp, line 1064
         Maybe there is better solution that not run this code in iOS, but right now I haven't enough time to search it for so minor feature
         */
        QFile file(fullFilePath);
        if(file.exists()){
            qDebug()<< id;
            QFileIconProvider provider;
            QFileInfo fileInfo = QFileInfo(fullFilePath);
            QIcon icon = provider.icon(fileInfo);
            result = icon.pixmap(90,90);
        }
#endif
        if (result.isNull()){
            result=QPixmap("://no_image.png");
        }
    }
    return result;
}
