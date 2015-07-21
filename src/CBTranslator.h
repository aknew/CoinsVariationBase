#ifndef CBTRANSLATOR_H
#define CBTRANSLATOR_H

#include <QTranslator>
#include <QVariantMap>

class CBTranslator : public QTranslator
        /*! \brief translator class
         * \details This class created because standart localization way uses non human readable files */
{
    Q_OBJECT

private:
    QString m_fullFileName; ///< path to load and save translation
    void save () const; ///< save collected translation

public:
    explicit CBTranslator(QObject *parent = 0);

    /*! \brief collect which phrases needs to be translated
        \details was created because there are a lot dynamicly generated forms which need to be translated
     */
    bool m_needCollect;

    /// \brief redefined method from QTranslation
    virtual bool load(const QString &filename,
                      const QString &directory,
                      const QString &search_delimiters  = QString(),
                      const QString &suffix  = QString());

    /// \brief redefined method from QTranslation
    virtual QString translate(const char *context, const char *sourceText, const char *disambiguation, int n) const;
signals:

public slots:

};

#endif // CBTRANSLATOR_H
