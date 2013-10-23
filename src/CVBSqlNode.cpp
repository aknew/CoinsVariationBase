#include "CVBSqlNode.h"

CVBSqlNode::CVBSqlNode(){
    mainChild="";
    listViewFields=NULL;
}


QVariant CVBSqlNode::getListViewFields(){
    if (this->listViewFields && this->listViewFields->count()>0)
        return QVariant(*this->listViewFields);
    else{
        return this->model->fieldList;
    }

}
