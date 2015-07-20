#ifndef CBTRANSLATOR_H
#define CBTRANSLATOR_H

#include <QTranslator>
#include <QVariantMap>

/*! This class created because standart localization way uses non human readable files */

class CBTranslator : public QTranslator
{
    Q_OBJECT

private:
    QString m_fullFileName;
    void save () const;

public:
    explicit CBTranslator(QObject *parent = 0);

    bool m_needCollect;
    virtual bool load(const QString &filename,
                      const QString &directory,
                      const QString &search_delimiters  = QString(),
                      const QString &suffix  = QString());

    virtual QString translate(const char *context, const char *sourceText, const char *disambiguation, int n) const;

signals:

public slots:

};

#endif // CBTRANSLATOR_H
