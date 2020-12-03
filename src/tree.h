#ifndef TREE_H
#define TREE_H

#include "pch.h"
#include "type.h"

enum NodeType{  //结点类型
    NODE_CONST, //常量
    NODE_VAR,   //变量
    NODE_EXPR,  //表达式
    NODE_TYPE,  //数据类型
    NODE_STMT,  //语句
    NODE_PROG,  //程序，根结点特有
};

enum OpType{      //运算符类型
    OP_EQ,        // ==
    OP_GT,        // >
    OP_LT,        // <
    OP_GE,        // >=
    OP_LE,        // <=
    OP_NE,        // !=
    OP_ADD,       // +
    OP_SUB,       // -
    OP_MUL,       // *
    OP_DIV,       // /
    OP_MOD,       // %
    OP_PRE_INC,   // 前++
    OP_PRE_DEC,   // 前--
    OP_POS_INC,   // 后++
    OP_POS_DEC,   // 后--
    OP_ASSIGN,    // =
    OP_ADD_ASSI,  // +=
    OP_SUB_ASSI,  // -=
    OP_MUL_ASSI,  // *=
    OP_DIV_ASSI,  // /=
    OP_MOD_ASSI,  // %=
    OP_AND,       // &&
    OP_OR,        // ||
    OP_NOT,       // !
    OP_ADDR       // &
};

enum StmtType {  //语句类型
    STMT_SKIP,   //空语句
    STMT_DECL,   //声明
    STMT_FUNC,   //函数
    STMT_IF,     //if语句
    STMT_WHILE,  //while语句
    STMT_FOR,    //for语句
    STMT_ASSI,   //赋值语句
    STMT_PRINTF, //标准输出语句
    STMT_SCANF,  //标准输入语句
    STMT_RETURN  //返回
};

struct TreeNode {
public:
    int nodeID;         //树结点序号
    void genNodeId();   //从根节点开始逐个赋Id

    int lineno;         //所在程序行号
    NodeType nodeType;  //结点类型
    TreeNode(int lineno, NodeType type);

    TreeNode* child;            //子结点
    TreeNode* sibling;          //兄弟结点
    void addChild(TreeNode*);   //添加子结点
    void addSibling(TreeNode*); //添加兄弟结点
    
    void printNodeInfo();       //输出结点基本信息
    void printSpecialInfo();    //根据结点类型输出相应信息
    void printChildrenId();     //输出子结点id
    void printAST();            //先输出自己+孩子们的id；再依次让每个孩子输出AST。

public:
    OpType optype;   //表达式结点，保存其运算符类型
    Type* type;      //常量、变量、类型结点的数据类型
    StmtType stype;  //语句结点的语句类型
    int int_val;     //int型常量的值
    char ch_val;     //char型常量的值
    bool b_val;      //bool型常量的值
    string str_val;  //string型常量的值
    string var_name; //变量名
    int symtableID;  //所在的符号表ID
    int varID;       //符号表内索引
    
public:
    //返回**类型的名称（字符串）
    static string nodeType2String (NodeType type);
    static string opType2String (OpType type);
    static string sType2String (StmtType type);

};

#endif