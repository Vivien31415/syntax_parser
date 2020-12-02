#ifndef TYPESYSTEM_H
#define TYPESYSTEM_H
#include "pch.h"

enum ValueType{
    VALUE_BOOL,
    VALUE_INT,
    VALUE_CHAR,
    VALUE_STRING,
    COMPOSE_STRUCT,
    COMPOSE_UNION,
    COMPOSE_FUNCTION
};

class Type{
public:
    ValueType type;
    Type(ValueType valueType);
    
public:  
    /* 如果你要设计复杂类型系统的话，可以修改这一部分 */
    ValueType* childType; // for union or struct
    ValueType* paramType, retType; // for function
    ValueType* sibling;   // 复杂类型中多个子类型
    void addChild(Type* t);
    void addParam(Type* t);
    void addRet(Type* t);

public:
    string getTypeInfo();   //返回类型名
};

// 设置几个常量Type，用于构建树结点，可以节省空间开销
static Type* TYPE_INT = new Type(VALUE_INT);
static Type* TYPE_CHAR = new Type(VALUE_CHAR);
static Type* TYPE_BOOL = new Type(VALUE_BOOL);
static Type* TYPE_STRING = new Type(VALUE_STRING);

//int getSize(Type* type);    //返回该数据类型所占空间大小

#endif