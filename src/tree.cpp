#include "tree.h"
int NODEID;

void TreeNode::addChild(TreeNode* child) {
    if(!child)
        return;
    if(this->child){
        //给没有兄弟的孩子添加兄弟
        TreeNode* p=this->child;
        while (p->sibling)
            p=p->sibling;
        p->sibling=child;
    }
    else
        this->child=child;
}

void TreeNode::addSibling(TreeNode* sibling){
    if(!sibling)
        return;
    if(this->sibling){
        //给没有兄弟的兄弟添加兄弟
        TreeNode* p=this->sibling;
        while (p->sibling)
            p=p->sibling;
        p->sibling=sibling;
    }
    else
        this->sibling=sibling;
}

TreeNode::TreeNode(int lineno, NodeType type) {
    this->lineno=lineno;
    this->nodeType=type;
    this->child=nullptr;
    this->sibling=nullptr;
    this->type=nullptr;
}


void TreeNode::genNodeId() {
    this->nodeID=NODEID++;
    if(this->child)
        this->child->genNodeId();
    if(this->sibling)
        this->sibling->genNodeId();
}

void TreeNode::printAST() {
    this->printNodeInfo();
    this->printSpecialInfo();
    this->printChildrenId();
    cout<<endl;
    if(this->child)
        this->child->printAST();
    if(this->sibling)
        this->sibling->printAST();  
}

void TreeNode::printNodeInfo() {
    //打印行号、结点号、结点类型
    cout<<"line@"<<left<<setw(5)<<this->lineno
         <<"@"<<setw(5)<<this->nodeID
         <<setw(12)<<TreeNode::nodeType2String(this->nodeType);
}

// You can output more info...
void TreeNode::printSpecialInfo() {
    switch(this->nodeType){
        case NODE_CONST:
            cout<<"类型: "<<left<<setw(10)<<this->type->getTypeInfo()
                 <<"值: ";
            switch (this->type->type){
                case VALUE_BOOL:
                    if(this->b_val)
                        cout<<"true";
                    else
                        cout<<"false";
                    break;
                case VALUE_INT:
                    cout<<this->int_val;
                    break;
                case VALUE_CHAR:
                    cout<<this->ch_val;
                    break;
                case VALUE_STRING:
                    cout<<this->str_val;
                    break;
                default:
                    break;
            }
            break;
        case NODE_VAR:
            if(!this->varID)
                cout<<this->var_name<<"未定义！";
            else{
                cout<<"类型: "<<left<<setw(10)<<this->type->getTypeInfo()
                    <<"名称: "<<setw(12)<<this->var_name
                    <<"作用域: "<<setw(6)<<this->symtableID
                    <<"符号表索引: "<<setw(6)<<this->varID;
                if(this->type->type==COMPOSE_FUNCTION){
                    if(this->type->retType)
                        cout<<"返回值"<<left<<setw(8)<<this->type->retType->getTypeInfo();
                    Type* p=this->type->paramType;
                    if(p)
                        cout<<"参数类型";
                    else
                        cout<<"无参数";
                    while(p){
                        cout<<left<<setw(8)<<p->getTypeInfo();
                        p=p->sibling;
                    }
                        
                }
            }
            break;
        case NODE_EXPR:
            cout<<"运算符: "<<left<<setw(6)<<TreeNode::opType2String(this->optype);
            break;
        case NODE_TYPE:
            cout<<this->type->getTypeInfo();
            break;
        case NODE_STMT:
            cout<<left<<setw(16)<<TreeNode::sType2String(this->stype);
            if(this->stype==STMT_ASSI)
                cout<<"运算符: "<<left<<setw(6)<<TreeNode::opType2String(this->optype);
            break;
        default:
            break;
    }
}

void TreeNode::printChildrenId() {
    if(this->child){
        cout<<"子节点:[@"<<this->child->nodeID;
        TreeNode* p=this->child->sibling;
        while(p){
            cout<<" @"<<p->nodeID;
            p=p->sibling;
        }
        cout<<']';
    }
}

string TreeNode::sType2String(StmtType type) {
    switch(type) {
        case STMT_SKIP:
            return "空语句";
        case STMT_DECL:
            return "声明";
        case STMT_FUNC:
            return "函数";
        case STMT_IF:
            return "if语句";
        case STMT_WHILE:
            return "while语句";
        case STMT_FOR:
            return "for语句";
        case STMT_ASSI:
            return "赋值语句";
        case STMT_PRINTF:
            return "printf语句";
        case STMT_SCANF:
            return "scanf语句";
        case STMT_RETURN:
            return "返回语句";
        default:
            cerr << "shouldn't reach here, stype";
            assert(0);
    }
    return "?";
}

string TreeNode::opType2String (OpType type){
    switch(type) {
        case OP_EQ:
            return "==";
        case OP_GT:
            return ">";
        case OP_LT:
            return "<";
        case OP_GE:
            return ">=";
        case OP_LE:
            return "<=";
        case OP_NE:
            return "!=";
        case OP_ADD:
            return "+";
        case OP_SUB:
            return "-";
        case OP_MUL:
            return "*";
        case OP_DIV:
            return "/";
        case OP_MOD:
            return "%";
        case OP_PRE_INC:
            return "前++";
        case OP_POS_INC:
            return "后++";
        case OP_PRE_DEC:
            return "前--";
        case OP_POS_DEC:
            return "后--";
        case OP_ASSIGN:
            return "=";
        case OP_ADD_ASSI:
            return "+=";
        case OP_SUB_ASSI:
            return "-=";
        case OP_MUL_ASSI:
            return "*=";
        case OP_DIV_ASSI:
            return "/=";
        case OP_MOD_ASSI:
            return "%=";
        case OP_AND:
            return "&&";
        case OP_OR:
            return "||";
        case OP_NOT:
            return "!";
        case OP_ADDR:
            return "&";
        default:
            cerr << "shouldn't reach here, optype";
            assert(0);
    }
    return "?";
}

string TreeNode::nodeType2String (NodeType type){
    switch(type) {
        case NODE_CONST:
            return "常量";
        case NODE_VAR:
            return "变量";
        case NODE_EXPR:
            return "表达式";
        case NODE_TYPE:
            return "数据类型";
        case NODE_STMT:
            return "语句";
        case NODE_PROG:
            return "程序";
        default:
            cerr << "shouldn't reach here, nodetype";
            assert(0);
    }
    return "?";
}
