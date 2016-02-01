#ifndef CBBASEICONPROVIDER_H
#define CBBASEICONPROVIDER_H

#include <QtQuick/QQuickImageProvider>


class CBBaseIconProvider : public QQuickImageProvider
{
public:
    CBBaseIconProvider(ImageType type);
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
    virtual QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize);

};



#endif // CBBASEICONPROVIDER_H
