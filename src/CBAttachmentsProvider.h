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
    Q_PROPERTY(QString currentId READ getCurrentID() NOTIFY attributesChanged())

    friend class CBImageProvider; //! for using currentPath
    friend class CBBaseProvider; //! for using _basePath

public:
    explicit CBAttachmentsProvider(const QString &basePath, QObject *parent = 0);

    /**
     * @brief selectID
     * @param newID - id (uuid) of some record in base which was selected
     */
    void selectID(const QString &newID);

    /*! \brief new attach will copied into record folder, name will push into json
     * If there wasn't Main.jpg and insertion is jpeg, new attach will renamed to Main.jpg.
     * It is not good practice that provider does it without notification to user, but my usual use case -
     * only one attach, this attach is image and I want to see it in listview
    */
    Q_INVOKABLE QVariantMap insertNewAttach(QString notePath);
    Q_INVOKABLE void updateAttributes(QVariantMap newAttributes); ///< attribute field list was changed in gui and it chould be saved
    Q_INVOKABLE void openAttach(const QString &attachID); ///< open attachment file in default external application
    /*! set this attachment file as default image (rename file to Main.jpg)
     * */
    Q_INVOKABLE void setMain(const QString &attachID);
    Q_INVOKABLE void openFolder();///< open attachment's folder
    Q_INVOKABLE void deleteAttach(const QString& noteID); ///< delete attach and it's attributes

    QString getCurrentID(){
        return *_selectedID;
    }

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
