#ifndef CBNOTESPROVIDER_H
#define CBNOTESPROVIDER_H

#include <QObject>
#include <QVariantList>

class CBAttachmentsProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList attributes MEMBER attributes NOTIFY attributesChanged())

public:
    explicit CBAttachmentsProvider(const QString &basePath,QObject *parent = 0);

    /**
     * @brief selectID
     * @param newID - id (uuid) of some record in base which was selected
     */
    void selectID(const QString &newID);

    void insertNewNote(const QString &notePath); ///< note will copied into record folder, attributes will push into json
    Q_INVOKABLE void updateAttributes(QVariantMap newAttributes); ///< note field list was changed ingui and it chould be saved

signals:
    void attributesChanged();

    /* TODO:
     * note deleting
     * note export
     */

private:
    QString _basePath; ///< root path of Attachments
    QString *_selectedID = NULL;
    QString attributePath(){
        return _basePath+*_selectedID + "/attributes.json";
    }
    QVariantList attributes;///< List of attachments for selected id with attributes, json array
    void saveAttributes(); ///<saves json with note's attributes to file into record folder

};

#endif // CBNOTESPROVIDER_H
