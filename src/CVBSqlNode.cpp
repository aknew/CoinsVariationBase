#include "CVBSqlNode.h"

CVBSqlNode::CVBSqlNode(){
    pictDelegate=-1;
    height=-1;
    columnWidth=NULL;
    mainChild="";
    listViewFields=NULL;
}


QVariant CVBSqlNode::getListViewFields(){
    if (this->listViewFields->count()>0)
        return QVariant(*this->listViewFields);
    else{
        return this->model->fieldList;
    }

}
