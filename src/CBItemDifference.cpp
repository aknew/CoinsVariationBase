#include "CBItemDifference.h"
#include "CBFieldDifference.h"
#include "CBWordLCS.h"

CBItemDifference::CBItemDifference(const QVariantMap &first, const QVariantMap &second, const QStringList &comparingFieldsList, QObject *parent) : QObject(parent)
{
    _first = first;
    _second = second;
    _comparingFieldsList = comparingFieldsList;

    id1 = _first["id"].toString();
    id2 = _second["id"].toString();

    this->recalculateDifferences();

}

void CBItemDifference::recalculateDifferences(){

    QList<QObject*> all;
    QList<QObject*> diff;
    for (auto iter: _first.keys()){
        if (_comparingFieldsList.contains(iter)){
            /*
             * FIXME: it seems, that it would be better if CBWordLCS will return CBFieldDifference
             * object, but I have some problems with copiing constructor QObject inheriter and using
             * plain C struct into QML. Actually, they aren't very difficult problem, but I prefer
             * not to spent time to them now
             */
            CBWordLCS wordLCS(_first[iter].toString(),_second[iter].toString());
            CBFieldDifference *fd = new CBFieldDifference(this); // TODO: Need check: possible memory leak?
            fd->_name = iter;
            fd->_highlightedFirst = wordLCS.getHighlitedFirst();
            fd->_highlightedSecond = wordLCS.getHighlitedSecond();
            fd->_differenceFirst = wordLCS.getDifferenceFirst();
            fd->_differenceSecond = wordLCS.getDifferenceSecond();
            fd->_isEqual =(fd->_differenceFirst == "" &&  fd->_differenceSecond == "");
            fd->_commonPart = wordLCS.commonPart();
            fd->_originalFirst = _first[iter].toString();
            fd->_originalSecond = _second[iter].toString();
            if (!fd->_isEqual){
                diff.append(fd);
            }
            all.append(fd);
        }
    }

    diffFieldsModel = diff;
    allFieldsModel = all;
}
