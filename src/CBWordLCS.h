#ifndef CBWORDLCS_H
#define CBWORDLCS_H

#include <QString>
#include <QStringList>

/**
 * @brief The CBWordLCS needs to compare strings and find it's difference
 * based on https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_subsequence#C.2B.2B *
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

    size_t   _m;
    size_t   _n;
    size_t *LCSTable;

    // Difference markers
    const QString kStartDifference = "<font color=\"red\">";
    const QString kEndDifference =   "</font>";

    size_t getAt(size_t i, size_t j) const;
    void setAt(size_t i, size_t j, size_t value);
    void backtrackOne(size_t i, size_t j);

    QStringList commonList;

    /**
     * @brief generateString
     * @param list - list to compare with commonList
     * @param generateDiff - what we should return generate - not common words or all string with highlighted difference
     * @return joined to string words
     */
    QString generateString(const QStringList &list, bool generateDiff);


};

#endif // CBWORDLCS_H
