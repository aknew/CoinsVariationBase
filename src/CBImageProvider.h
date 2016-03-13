#ifndef CBIMAGEPROVIDER_H
#define CBIMAGEPROVIDER_H


#include <QtQuick/QQuickImageProvider>

#include "CBAttachmentsProvider.h"

class CBImageProvider : public QQuickImageProvider
{

public:
    CBImageProvider( ImageType type, bool _isMainProvider = false);
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
    virtual QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize);

    CBAttachmentsProvider *attachmentsProvider;
private:
    bool isMainProvider; ///<if this provider is main provider, it should show files by record UUID + Main.jpg
};

#endif // CBIMAGEPROVIDER_H
