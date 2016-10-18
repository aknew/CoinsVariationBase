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
    QString commonPart(){
        return commonList.join(" ");
    }

private:
    QStringList firstList;
    QStringList secondList;

    int   _m;
    int   _n;
    int *LCSTable;

    // Difference markers
    const QString kStartDifference = "<font color=\"red\">";
    const QString kEndDifference =   "</font>";

    int getAt(int i, int j) const;
    void setAt(int i, int j, int value);
    void backtrackOne(int i, int j);

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
