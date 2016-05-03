#ifndef CBUTILS_H
#define CBUTILS_H
#include <QString>

///* \brief module for some small functions which are used in several classes
namespace CBUtils {
/**
 * @brief reduce file:// from pathes
 * @param str - string to reduce
 * Qml uses path with file:// protocol in the beginning, but qt c++ don't use it, so I need to reduse protocol path
 * Also for windows FileDialogs add / to the beginning (i.e. full path looks "file:///C:/test.txt"), but, for example, Qfile can't read these pathes
 */
void FromQmlFilePath(QString *str);
void SaveStringToFile(const QString &stringToSave, const QString &filePath); /// saving string as text file
void collectTranslation(const QString &original); ///save phrases which need to be translated to specific files, uses for collect those phrases

/** \brief recursivly coping files and dirs
 *  original code: https://gist.github.com/ssendeavour/7324701
 */
bool copyRecursively(const QString &srcFilePath,
                            const QString &tgtFilePath);
}

#endif // CBUTILS_H
