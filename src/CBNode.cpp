#include "CBNode.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QtSql>
#include <QDebug>

#include "CBBaseProvider.h"
#include "CBItemDifference.h"
#include "CBUtils.h"

const QString kWrongString = "*wrongString*"; //< marker that some string wasn't filled

CBNode::CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent) : QObject(parent), db(db), levelFilter(kWrongString,kWrongString)
{

    filter = "";

    // TODO: Добавить проверку что все хорошо прошло, проще здесь найти что таблица называется не так как в struct.json чем отлавливать это в qml
    tableName=obj.value("name").toString();

    //TODO: Need create model only when it used and delete it when we don't use it
    m_listModel=new CBSqlRelationalTableModel(this,db);
    m_listModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    m_listModel->setTable(this->tableName);
    m_listModel->applyRoles();

    QJsonValue json_usesUUIDs = obj.value("usesUUIDs");
    if (!json_usesUUIDs.isUndefined()){
        usesUUIDs = json_usesUUIDs.toBool();
    }

    QJsonValue json_editable = obj.value("editable");
    if (!json_editable.isUndefined()){
        editable = json_editable.toBool();
    }

    QJsonValue json_useFullForm = obj.value("useFullForm");
    if (!json_useFullForm.isUndefined()){
            useFullForm = json_useFullForm.toBool();
    }

    QJsonValue json_useListForm = obj.value("useListForm");
    if (!json_useListForm.isUndefined()){
            useListForm = json_useListForm.toBool();
    }

    QJsonValue json_sortColumn = obj.value("sortColumn");
    if (!json_sortColumn.isUndefined()){
        QString sortColumn = json_sortColumn.toString();
        m_listModel->sortByColumn(sortColumn);
    }


    QJsonArray json_childNodes = obj.value("childNode").toArray();
    foreach (QJsonValue value1,json_childNodes) {
        QString name;
        if (value1.isString()){
            name = value1.toString();
            this->childNodes.insert(
                        name,
                        "parentId"
                        );
        }
        else{

            QJsonObject obj=value1.toObject();
            name = obj.value("name").toString();
            this->childNodes.insert(
                    name,
                    obj.value("relation").toString()
                    );
        }

        _nextLevelList.append(name);
    }

    QJsonArray json_filters = obj.value("filters").toArray();
    foreach (QJsonValue value1,json_filters) {
        QJsonObject obj=value1.toObject();
        this->predefinedFiltes.insert(
                obj.value("name").toString(),
                obj.value("condition").toString()
                );
    }

    // TODO: need generate listViewFields and fullFormFields only when it need if it doesn't exists into json
    QJsonValue  json_listViewFields = obj.value("listViewFields");
    if ( json_listViewFields.isArray()){
        this->listViewFields = json_listViewFields.toVariant();
    }
    else {
        this->listViewFields =QVariant(this->m_listModel->fieldList);
    }

    QJsonValue json_fullFormFields = obj.value("fullFormFields");



    if ( json_fullFormFields.isArray()){
        this->fullFormFields =  json_fullFormFields.toVariant();
        foreach (QJsonValue value1,json_fullFormFields.toArray()) {

            if (value1.isString()){
                fullFormFieldsInternal.append(value1.toString());
            }
            else{
                QJsonObject obj=value1.toObject();
                fullFormFieldsInternal.append(obj.value("name").toString());
            }
        }

    }
    else {
        fullFormFieldsInternal = this->m_listModel->fieldList;

        json_fullFormFields = obj.value("fullFormExceptedFields");
        if (json_fullFormFields.isArray()){
            foreach (QJsonValue value1,json_fullFormFields.toArray()) {
                fullFormFieldsInternal.removeAll(value1.toString());
            }
        }

        this->fullFormFields =QVariant(fullFormFieldsInternal);
    }
}

QString CBNode::listFormName(){
    return tableName+"List.qml";
}

QString CBNode::fullFormName(){
    return tableName+"Full.qml";
}

QPair<QString, QString> CBNode::filterForChildNode(const QString& childNodeName){
    QString str=childNodes.value(childNodeName);
    if (str==""){
        return QPair<QString, QString>(kWrongString,kWrongString);
    }
    return QPair<QString, QString>(str,m_listModel->selectedItemId());
}

void CBNode::setLevelFilter(const QPair<QString, QString> &filter){
    levelFilter = filter;
    applyFilters();
}

QString CBNode::getFilter(){
    return filter;
}

void CBNode::setFilter(const QString &filterString){
    filter = filterString;
    qDebug() << "filter string: " << filterString;
    applyFilters();
}

void CBNode::dropFilter(){
    // TODO: use setFilter instead
    filter = "";
    applyFilters();
}

void CBNode::applyFilters(){

    QString fullFilterString = filter;

    QString s_levelFilter  = kWrongString;

    if (levelFilter.first!=kWrongString){
        s_levelFilter = levelFilter.first + "=\"" + levelFilter.second + "\"";
    }
    if (s_levelFilter!=kWrongString){
        if (filter == ""){
            fullFilterString = s_levelFilter;
        }
        else{
            fullFilterString = s_levelFilter + " and " + fullFilterString;
        }
    }

    m_listModel->setFilter(fullFilterString);
    m_listModel->select();


}

QStringList CBNode::listFromQuery(QString queryString){

    QSqlQuery query(db);

    bool flag = query.exec(queryString);

    if (!flag){
        qDebug()<<query.lastError();
    }

    QStringList list;
    list << "";
    while (query.next()) {
        QString str = query.value(0).toString();
        // HOTFIX: For default empty string. I don't use sql condition because I don't want to add
        // restrictions to query field of struct json
        if (str == ""){
           continue;
        }
        list<<str;
    }

    return list;

}

int CBNode::findRowWithID(const QString &selID)
{
    for (int i = 0; i< m_listModel->rowCount(); ++i){
        QSqlRecord record=m_listModel->record(i);
        QSqlField id=record.field("id");
        if (id.value().toString() == selID){
            return i;
        }
    }
    //XXX: Maybe not best practice, rewrite with exaption?
    qCritical()<<"There is no record with id "<<selID;
    return -1;
}

void CBNode::selectItemWithIndex(int index){
    m_listModel->selectedRow = index;
    emit idWasSelected(m_listModel->selectedItemId());

}

QVariantMap CBNode::itemAtIndex(int index){

    return m_listModel->itemForRow(index);
}

void CBNode::prepareToNewItem(){
    insertingNewRow = true;

    QSqlRecord record;

    if(levelFilter.first!=kWrongString){
        // add filters - foreign keys
        QSqlField f1(levelFilter.first, QVariant::String);
        f1.setValue(QVariant(levelFilter.second));
        record.append(f1);
    }
    if(usesUUIDs){
        QSqlField f1("id", QVariant::String);
        QUuid u=QUuid::createUuid();
        f1.setValue(QVariant(u.toString()));
        record.append(f1);
    }
    if (!m_listModel->insertRecord(-1, record)){
        qDebug()<<m_listModel->lastError();
    }

    selectItemWithIndex(m_listModel->rowCount()-1);
}

void CBNode::cloneItem(){
    insertingNewRow = true;
    QSqlRecord record = m_listModel->record(m_listModel->selectedRow);
    if(usesUUIDs){
        QSqlField f1("id", QVariant::String);
        QUuid u=QUuid::createUuid();
        f1.setValue(QVariant(u.toString()));
        record.append(f1);
    }
    if (!m_listModel->insertRecord(-1, record)){
        qDebug()<<m_listModel->lastError();
    }

    selectItemWithIndex(m_listModel->rowCount()-1);
}

void CBNode::applyChanges(QVariantMap changedItem){
    QString uuid = m_listModel->selectedItemId();
    m_listModel->setSelectedItem(changedItem);
    m_listModel->selectedRow = findRowWithID(uuid);
    if (insertingNewRow){
        insertingNewRow = false;
    }
}

void CBNode::dropChanges(){
    if (insertingNewRow){
       insertingNewRow = false;
       m_listModel->removeCurrentItem();
    }
}

void CBNode::deleteSelectedItem(){
    // FIXME: rename from delete to remove
    if (usesUUIDs){
        emit currentItemWillBeRemoved();
    }

    m_listModel->removeCurrentItem();
}

QString CBNode::selectedItemDescription(){
    QString str = "<b>"+tr(tableName.toStdString().c_str()) + "</b>:<br>";
    QVariantMap selected = this->selectedItem();
    for (auto iter: listViewFields.toStringList()){
        // TODO: need load formated string from json and fill it
        if (selected.contains(iter)){
            str = str + tr(iter.toStdString().c_str())+": " + selected[iter].toString() + "<br>";
        }
    }
    return str;
}

CBItemDifference *CBNode::recordDifference(int index1, int index2){
    QVariantMap map1 = itemAtIndex(index1);
    QVariantMap map2 = itemAtIndex(index2);
    CBItemDifference *difference = new CBItemDifference(map1, map2, fullFormFieldsInternal, this);
    return difference;
}

bool CBNode::mergeRecords(QString src, QString dst, QVariantMap mergedItem, QString diff){

    for (auto key : childNodes.keys()){
        // FIXME: if it is unique constraint in table nothing will apply, but another query canbe already applied. Need add transactions
        QString str=childNodes.value(key);
        if (str!=""){ // Some subnodes are not based on current (for example SourceList), usualy it is separate entityes which was add as childNode to have only one enterance point
            QString q = "update %1 set comment =  ifnull(:COMMENT||';'||comment,:COMMENT), %2 = :NEWID where %2 = :OLDID";
            q = q.arg(key).arg(str);
            qDebug()<<q;
            QSqlQuery query = QSqlQuery(db);
            query.prepare(q);
            query.bindValue(":COMMENT",diff);
            query.bindValue(":NEWID",dst);
            query.bindValue(":OLDID",src);
            bool flag = query.exec();
            if (!flag){
                qWarning()<< "Update subnode error: "<< query.lastError() << "\n query: "<<query.executedQuery();
                return false;
            }
        }
    }

    CBBaseProvider *bp = qobject_cast<CBBaseProvider *>(parent());
    bp->attachmentsProvider->mergeAttachments(src, dst, diff);

    m_listModel->selectedRow = findRowWithID(dst);
    applyChanges(mergedItem);
    m_listModel->selectedRow = findRowWithID(src);
    deleteSelectedItem();
    return true;
}

void CBNode::exportListToFile(const QString &path){

    if (!QDir(path).exists()){
        QDir().mkdir(path);
    }

    // TODO: export can be long and should be async

    QFile saveFile(path+"/list.json");

    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open translation file to write.");
    }

    QJsonDocument saveDoc(QJsonArray::fromVariantList(listForExport(path)));
    saveFile.write(saveDoc.toJson());

}

QVariantList CBNode::listForExport(const QString &path){

    QVariantList vl;

    CBBaseProvider *bp = qobject_cast<CBBaseProvider *>(parent());
    QString &attachBasePath = bp->attachmentsProvider->_basePath;

    QList<CBNode *> exportingSubnodes;

    for (auto it : childNodes.keys()){
        CBNode * cn = bp->getNode(it);
        if (!cn->usesUUIDs){
            // TODO: need create way to select which subnodes will be exported as graph
            exportingSubnodes.append(cn);
        }
    }

    for (int i = 0; i < this->m_listModel->rowCount(); ++i){
        QVariantMap map = itemAtIndex(i);

        // FIXME: do "id" and "attributes.json" constant strings, also need move all actions with attachment into attachment provider
        QString id = map.contains("id")?map["id"].toString():"";

        // add attachments if they are exist
        QString recordAttachPath = attachBasePath  + id;

        if (usesUUIDs && QDir(recordAttachPath).exists()){
            QFile file( recordAttachPath +"/"+ "attributes.json");
            if (!file.open(QIODevice::ReadOnly)){
                qDebug() << "Cannot open attach file to read";
            }
            QString jsonData = file.readAll();
            file.close();

            QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

            if (sd.isNull()){
               qWarning("Wrong file attribute json format");
            }

            map["attachments"] = sd.object().toVariantMap();

            CBUtils::copyRecursively(recordAttachPath,path+"/"+id);
            QFile::remove(path+"/"+id+"/"+ "attributes.json"); // remove attributes,json - it merget with main json

        }

        for (CBNode *node : exportingSubnodes){
            QString str=childNodes.value(node->tableName);
            if (str!=""){
                node->setLevelFilter(QPair<QString, QString>(str,id));
            }
            QVariantList list = node->listForExport(path);
            if (!list.empty()){
                map[node->tableName] = list;
            }
        }
        vl.append(map);
    }
    qDebug()<<vl.count()<< " prepared for export for table " << this->tableName;
    return vl;
}

void CBNode::applyPredefinedFilter(const QString &f){
    // TODO: use setFilter instead
    filter = predefinedFiltes[f];
    applyFilters();
}
