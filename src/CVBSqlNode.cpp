#include "CVBSqlNode.h"

CVBSqlNode::CVBSqlNode(){
    listViewFields=NULL;
    listModel = NULL;
}


QVariant CVBSqlNode::getListViewFields(){
    if (this->listViewFields && this->listViewFields->count()>0)
        return QVariant(*this->listViewFields);
    else{
        return this->model->fieldList;
    }
}
