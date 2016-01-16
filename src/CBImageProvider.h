#ifndef CBIMAGEPROVIDER_H
#define CBIMAGEPROVIDER_H


#include <QtQuick/QQuickImageProvider>

#include "CBAttachmentsProvider.h"

class CBImageProvider : public QQuickImageProvider
{

public:
    CBImageProvider( ImageType type);
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
    virtual QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize);

    QString saveImage(QByteArray attach);
    CBAttachmentsProvider *attachmentsProvider;
};

#endif // CBIMAGEPROVIDER_H
