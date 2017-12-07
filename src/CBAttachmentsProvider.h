#ifndef CBNOTESPROVIDER_H
#define CBNOTESPROVIDER_H

#include <QObject>
#include <QVariantList>

class CBAttachmentsProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList attributes MEMBER attributes NOTIFY attributesChanged())
    Q_PROPERTY(QString currentId READ getCurrentID() NOTIFY attributesChanged())
    Q_PROPERTY(QString mainImage MEMBER mainImage NOTIFY mainImageChanged())

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

    void removeSelectedIdAttaches();
    QString _basePath; ///< root path of Attachments
    QString mainImage;

    /**
     * @brief mergeAttachments merge attachments of 2 records
     * @param srcId - source record id, all attach,ents from it will be moved to destination record, it's folder will remove
     * @param dstID - destination record id
     * @param diff - short message which will be added to all attachments from source as comment
     */
    void mergeAttachments(const QString &srcId, const QString &dstID,const QString &diff);

signals:
    void attributesChanged();
    void mainImageChanged();

private:
    QString *_selectedID = NULL;
    inline QString attributePath(const QString &recId = ""){
        return pathForId(recId)+ "attributes.json";
    }

    QVariantList attributes;///< List of attachments for selected id with attributes, json array
    void saveAttributes(); ///<saves json with note's attributes to file into record folder

    inline QString pathForId(QString recId=""){
        if (recId == ""){
            recId= *_selectedID;
        }
        return _basePath+recId + "/";
    }

    QVariantList attributesForId(const QString &recId = "");
};

#endif // CBNOTESPROVIDER_H
