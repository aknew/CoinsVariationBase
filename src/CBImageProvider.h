#ifndef CBIMAGEPROVIDER_H
#define CBIMAGEPROVIDER_H


#include <QtQuick/QQuickImageProvider>

class CBImageProvider : public QQuickImageProvider
{

public:
    CBImageProvider( ImageType type);
    QString imageFolder;
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
    virtual QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize);

    QString saveImage(QByteArray attach);
};

#endif // CBIMAGEPROVIDER_H
