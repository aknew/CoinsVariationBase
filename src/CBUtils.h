#ifndef CBUTILS_H
#define CBUTILS_H
#include <QString>

///* \brief module for some small functions which are used in several classes
namespace CBUtils {
void FromQmlFilePath(QString *str);
void SaveStringToFile(const QString &stringToSave, const QString &filePath);

}


#endif // CBUTILS_H
