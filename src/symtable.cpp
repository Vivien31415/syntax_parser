#include "symtable.h"

Item::Item(){
    this->type=nullptr;
}

Item::Item(string name,Type* type){
    this->name=name;
    this->type=type;
}

int scopenum=1;       //记录作用域数
int scopestack[10]={0}; //记录当前有效作用域,作用域从0编号
int sp=0;             //作用域栈指针
int symbolnum=0;      //记录当前符号表长度,符号表项从1编号
map<int,map<int,Item*>*> symtables;  //多级符号表，区分作用域
map<int,Item*>::reverse_iterator iter; //符号表反向遍历器
Item* item;  //暂存符号表项
map<int,Item*>* symtable;   //暂存符号表
