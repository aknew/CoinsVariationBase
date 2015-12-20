#ifndef CBNOTESPROVIDER_H
#define CBNOTESPROVIDER_H

#include <QObject>

#include <QJsonArray>

class CBNotesProvider : public QObject
{
    Q_OBJECT
public:
    explicit CBNotesProvider(const QString &basePath,QObject *parent = 0);

    /**
     * @brief selectID
     * @param newID - id (uuid) of some record in base which was selected
     */
    void selectID(const QString &newID);
    QJsonArray *notes(){ ///< List of notes for selected id with attributes, json
        return &attributes;
    }

    void insertNewNote(const QString &notePath); ///< note will copied into record folder, attributes will push into json
    void saveAttributes(); ///<saves json with note's attributes to file into record folder

    /* TODO:
     * note deleting
     * note export
     */

private:
    QString _basePath; ///< root path of Notes
    QString *_selectedID = NULL;
    QString notesAttributePath(){
        return _basePath+*_selectedID + "/attributes.json";
    }
    QJsonArray attributes;

};

#endif // CBNOTESPROVIDER_H
