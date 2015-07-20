#ifndef CBUTILS_H
#define CBUTILS_H
#include <QString>
namespace CBUtils {

void FromQmlFilePath(QString *str);
void SaveStringToFile(const QString &stringToSave, const QString &filePath);

}


#endif // CBUTILS_H
