#include "CVBUtils.h"

void CVBFromQmlFilePath(QString *str){
    if (str->startsWith("file:///")){
        str->remove("file:///");
    }
}
