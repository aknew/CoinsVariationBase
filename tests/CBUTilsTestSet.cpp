#include "CBUTilsTestSet.h"

#include <QTest>

#include "../src/CBUtils.h"

void CBUTilsTestSet::stringDifference(){
    QString str1 = "шаблон №1, розетка образца 1730г., пятилепестковая, в форме цветка, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";
    QString str2 = "шаблон №2, розетка образца 1730г., пятилепестковая, другого рисунка, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";

    const QString exceptedResult1 = "шаблон <font color=\"red\">№1</font>, розетка образца 1730г., пятилепестковая, <font color=\"red\">в форме цветка</font>, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";
    const QString exceptedResult2 = "шаблон <font color=\"red\">№2</font>, розетка образца 1730г., пятилепестковая, <font color=\"red\">другого рисунка</font>, боковые ветви - по тринадцать листочков с каждой стороны, нижние ветви пальмовые с обвязкой (бантом)";

    const QString exceptedDiff1 = "№1; в форме цветка";
    const QString exceptedDiff2 = "№2; другого рисунка";

    QString diff1 = "";
    QString diff2 = "";

    CBUtils::stringDifference(str1,str2,diff1,diff2);

    QCOMPARE(exceptedResult1, str1);
    QCOMPARE(exceptedResult2, str2);
    QCOMPARE(exceptedDiff1, diff1);
    QCOMPARE(exceptedDiff2, diff2);
}
