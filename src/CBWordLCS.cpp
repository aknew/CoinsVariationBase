#include "CBWordLCS.h"
#include <QDebug>

CBWordLCS::CBWordLCS(const QString &first, const QString &second)
{
    // I use word as atomic elements
    firstList = first.split(" ");
    secondList = second.split(" ");
    _m = firstList.length();
    _n = secondList.length();
    LCSTable = new size_t[(_m + 1) * (_n + 1)];

    for (size_t i=0; i<=_m; ++i){
        setAt(i, 0, 0);
    }

    for (size_t j=0; j<=_n; ++j){
        setAt(0, j, 0);
    }

    for (size_t i = 0; i < _m; ++i){
        for (size_t j = 0; j < _n; ++j){
            if (firstList.at(i) == secondList.at(j))
                setAt(i+1, j+1, getAt(i, j)+1);
            else
                setAt(i+1, j+1, std::max(getAt(i+1, j), getAt(i, j+1)));
        }
    }
    backtrackOne(_m,_n);

    //qDebug()<< commonList.join(" ");
}


QString CBWordLCS::getHighlitedFirst(){
    return generateString(firstList, false);
}

QString CBWordLCS::getHighlitedSecond(){
    return generateString(secondList, false);
}

QString CBWordLCS::getDifferenceFirst(){
    return generateString(firstList, true);
}

QString CBWordLCS::getDifferenceSecond(){
    return generateString(secondList, true);
}

void CBWordLCS::setAt(size_t i, size_t j, size_t value)
{
    LCSTable[i + j * (_m + 1)] = value;
}

size_t CBWordLCS::getAt(size_t i, size_t j) const
{
    return LCSTable[i + j * (_m + 1)];
}

void CBWordLCS::backtrackOne(size_t i, size_t j){
        commonList.clear();

        if (i == 0 || j == 0)
            return;

        if (firstList.at(i - 1) == secondList.at(j - 1)){
            backtrackOne(i - 1, j - 1);
            commonList.push_back(firstList.at(i - 1));
            return;
        }

        if (getAt(i, j - 1) > getAt(i -1, j))
            backtrackOne(i, j - 1);
        else
            backtrackOne(i - 1, j);
}

QString CBWordLCS::generateString(const QStringList &list, bool generateDiff){

    QStringList result;

    bool stackingDiff = false;
    auto clIter = commonList.begin();
    for(auto iter = list.begin(); iter!= list.end(); ++iter){
        if (*iter == *clIter){
            if (!generateDiff){
                if (stackingDiff){
                    stackingDiff = false;
                    result.push_back(kEndDifference);
                }
                result.push_back(*iter);
            }
            ++clIter;
            if (clIter == commonList.end()){
                // push all remaining elements to result
                if (!generateDiff && !stackingDiff){
                    result.push_back(kStartDifference);
                }
                for(auto subIter = iter; subIter!= list.end(); ++ subIter){
                    result.push_back(*subIter);
                }
                if (!generateDiff){
                    result.push_back(kEndDifference);
                }
                break;
            }
        }
        else{
            if (!generateDiff){
                if (!stackingDiff){
                    stackingDiff = true;
                    result.push_back(kStartDifference);
                }
            }
            result.push_back(*iter);
        }
    }
    return result.join(" ");
}
