#ifndef CVBIMAGEPROVIDER_H
#define CVBIMAGEPROVIDER_H

#include <QtQuick/QQuickImageProvider>

class CVBImageProvider : public QQuickImageProvider
{
public:
    CVBImageProvider( ImageType type);
    QString imageFolder;
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
    virtual QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize);
};

#endif // CVBIMAGEPROVIDER_H
