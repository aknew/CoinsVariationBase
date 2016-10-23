#ifndef CBATTACHMENTPROVIDERTESTSET_H
#define CBATTACHMENTPROVIDERTESTSET_H

#include <QObject>

class CBAttachmentProviderTestSet : public QObject
{
    Q_OBJECT
public:
    explicit CBAttachmentProviderTestSet(QObject *parent = 0);

private slots:
    void mergeAttachTest();
};

#endif // CBATTACHMENTPROVIDERTESTSET_H
