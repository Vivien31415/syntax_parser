#ifndef SYMTABLE_H
#define SYMTABLE_H

#include "pch.h"
#include "type.h"

//符号表项
struct Item{          //符号表项
    string name;      //变量名
    Type* type;       //变量类型
    Item();
    Item(string name,Type* type);
};
extern int scopenum;       //记录作用域数
extern int scopestack[10]; //记录当前有效作用域,作用域从0编号
extern int sp;             //作用域栈指针
extern map<int,map<int,Item*>*> symtables;  //多级符号表，区分作用域
extern map<int,map<int,Item*>*>::iterator it;
extern map<int,Item*>::reverse_iterator iter; //符号表反向遍历器
extern Item* item;  //暂存符号表项
extern map<int,Item*>* symtable;   //暂存符号表

#endif