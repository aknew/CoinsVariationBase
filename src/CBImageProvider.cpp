#include "CBImageProvider.h"
#include <QDebug>
#include <QFile>
#include <QFileIconProvider>

CBImageProvider::CBImageProvider(ImageType type, bool _isMainProvider):
    QQuickImageProvider(type),
    isMainProvider(_isMainProvider)
{

}

QImage CBImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return QImage(attachmentsProvider->currentPath()+id);
}

QPixmap CBImageProvider::requestPixmap(const QString& id, QSize* size, const QSize& requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    QString fullFilePath = isMainProvider?attachmentsProvider->mainImagePath(id):attachmentsProvider->currentPath()+id;
    QPixmap result= QPixmap(fullFilePath);

    if (result.isNull()){
        if (isMainProvider){
            result=QPixmap("://no_image.png");
        }else{
            QFileIconProvider provider;
            QIcon icon = provider.icon(fullFilePath);
            if (icon.isNull()){ // FIXME: not null, but icon is wrong
                result=QPixmap("://no_image.png");
            }
            else{
                result = icon.pixmap(90,90);
            }
        }

    }

    return result;
}
