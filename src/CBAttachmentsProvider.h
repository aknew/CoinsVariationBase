#ifndef CBNOTESPROVIDER_H
#define CBNOTESPROVIDER_H

#include <QObject>
#include <QVariantList>

class CBImageProvider;
class CBBaseProvider;

class CBAttachmentsProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList attributes MEMBER attributes NOTIFY attributesChanged())

    friend class CBImageProvider; //! for using currentPath
    friend class CBBaseProvider; //! for using _basePath

public:
    explicit CBAttachmentsProvider(const QString &basePath,QObject *parent = 0);

    /**
     * @brief selectID
     * @param newID - id (uuid) of some record in base which was selected
     */
    void selectID(const QString &newID);

    Q_INVOKABLE QVariantMap insertNewAttach(QString notePath); ///< new attach will copied into record folder, attributes will push into json
    Q_INVOKABLE void updateAttributes(QVariantMap newAttributes); ///< attribute field list was changed in gui and it chould be saved
    Q_INVOKABLE void openAttach(const QString &attachID); ///< open attachment file in default external application
    Q_INVOKABLE void openFolder();///< open attachment's folder
    Q_INVOKABLE void deleteAttach(const QString& noteID); ///< delete attach and it's attributes

signals:
    void attributesChanged();

private:
    QString _basePath; ///< root path of Attachments
    QString *_selectedID = NULL;
    inline QString attributePath(){
        return currentPath()+ "attributes.json";
    }
    QVariantList attributes;///< List of attachments for selected id with attributes, json array
    void saveAttributes(); ///<saves json with note's attributes to file into record folder
    inline QString currentPath(){
        return _basePath+*_selectedID + "/";
    }

};

#endif // CBNOTESPROVIDER_H
