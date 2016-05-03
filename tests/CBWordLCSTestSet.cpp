#include "CBWordLCSTestSet.h"

#include <QTest>

#include "../src/CBWordLCS.h"

void CBWordLCSTestSet::stringDifference(){
    QString str1 = "шаблон №1, розетка образца 1730г., пятилепестковая, в форме цветка, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";
    QString str2 = "шаблон №2, розетка образца 1730г., пятилепестковая, другого рисунка, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";

    const QString exceptedResult1 = "шаблон <font color=\"red\"> №1, </font> розетка образца 1730г., пятилепестковая, <font color=\"red\"> в форме цветка, </font> боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";
    const QString exceptedResult2 = "шаблон <font color=\"red\"> №2, </font> розетка образца 1730г., пятилепестковая, <font color=\"red\"> другого рисунка, </font> боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";

    const QString exceptedDiff1 = "№1, в форме цветка,";
    const QString exceptedDiff2 = "№2, другого рисунка,";

    CBWordLCS wordLCS(str1, str2);

    qDebug() << wordLCS.getHighlitedFirst();
    qDebug() << exceptedResult1;

    QCOMPARE(exceptedResult1, wordLCS.getHighlitedFirst());
    QCOMPARE(exceptedResult2, wordLCS.getHighlitedSecond());
    QCOMPARE(exceptedDiff1, wordLCS.getDifferenceFirst());
    QCOMPARE(exceptedDiff2, wordLCS.getDifferenceSecond());

    // TODO: check ending and beginning not common elements
}
