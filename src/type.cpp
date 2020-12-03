#include "type.h"

Type::Type(ValueType valueType) {
    this->type = valueType;
    this->childType=nullptr;
    this->paramType=nullptr;
    this->retType=nullptr;
}

string Type::getTypeInfo() {
    switch(this->type) {
        case VALUE_VOID:
            return "void";
        case VALUE_BOOL:
            return "bool";
        case VALUE_INT:
            return "int";
        case VALUE_CHAR:
            return "char";
        case VALUE_STRING:
            return "string";
        case VALUE_ADDR:
            if(this->childType)
                return "addr of "+this->childType->getTypeInfo();
            else
                return "addr of ?";
        case COMPOSE_STRUCT:
            return "struct";
        case COMPOSE_UNION:
            return "union";
        case COMPOSE_FUNCTION:
            return "function";
        default:
            cerr << "shouldn't reach here, typeinfo";
            assert(0);
    }
    return "?";
}

void Type::addChild(Type* t){
    if(!t)
        return;
    if(this->childType){
        Type* p=this->childType;
        while(p->sibling)
            p=p->sibling;
        p->sibling=t;
    }
    else{
        this->childType=t;
    }
}

void Type::addParam(Type* t){
    if(!t)
        return;
    if(this->paramType){
        Type* p=this->paramType;
        while(p->sibling)
            p=p->sibling;
        p->sibling=t;
    }
    else{
        this->paramType=t;
    }
}
