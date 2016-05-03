#ifndef CBWORDLCS_H
#define CBWORDLCS_H

#include <QString>
#include <QStringList>

/**
 * @brief The CBWordLCS needs to compare strings and find it's difference
 */

class CBWordLCS
{
public:
    CBWordLCS(const QString &first, const QString &second);
    QString getHighlitedFirst();
    QString getHighlitedSecond();
    QString getDifferenceFirst();
    QString getDifferenceSecond();

private:
    QStringList firstList;
    QStringList secondList;

    size_t *LCSTable;

    // Difference markers
    const QString startDifference = "<font color=\"red\">";
    const QString endDifference =   "</font>";


};

#endif // CBWORDLCS_H
