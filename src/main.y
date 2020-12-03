%{
    #include "common.h"
    #define YYSTYPE TreeNode *
    #define YYDEBUG 1
    TreeNode* root;
    extern int lineno;
    int yylex();
    int yyerror( char const * );
      
%}
%token T_INT T_VOID T_BOOL T_CHAR T_STRING
%token IF WHILE FOR PRINTF SCANF RETURN
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE
%token CHAR INT STRING BOOL ID
%right ASSIGN ADD_ASSI SUB_ASSI MUL_ASSI DIV_ASSI MOD_ASSI
%left OR
%left AND
%left EQ NE
%left GT LT GE LE
%left ADD SUB
%left MUL DIV MOD
%right NOT INC DEC UPLUS UMINUS ADDR
%right POST_INC POST_DEC

%%
program
    : statements {
        //开始分析程序
        root=new TreeNode(0, NODE_PROG); 
        root->addChild($1);
    }
    ;

statements
    :  statement {$$=$1;}
    |  statements statement {$$=$1; $$->addSibling($2);}
    ;

statement
    : SEMICOLON  {$$=new TreeNode(lineno, NODE_STMT); $$->stype = STMT_SKIP;}
    | decl SEMICOLON {$$=$1;}
    | expr_list SEMICOLON {$$=$1;}
    | funcdef {$$=$1;}
    | if_else {$$=$1;}
    | while {$$=$1;}
    | for {$$=$1;}
    | printf SEMICOLON {$$=$1;}
    | scanf SEMICOLON {$$=$1;}
    | block {$$=$1;}
    | RETURN expr SEMICOLON {
        $$=new TreeNode(lineno, NODE_STMT);
        $$->stype = STMT_RETURN;
        $$->addChild($2);
    }
    ;

block
    : LBRACE statements RBRACE {$$=$2;}
    | LBRACE RBRACE {$$=nullptr;}
    ;

funcdef
    : type ID LPAREN RPAREN block {
        //无参数函数定义
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_FUNC;
        $$->addChild($2);
        $$->addChild($5);
        //设置函数名的返回类型
        $2->type=new Type(COMPOSE_FUNCTION);
        $2->type->retType=$1->type;
        //添加符号表项
        $2->symtableID=scopestack[sp];
        item=new Item($2->var_name,$2->type);
        it=symtables.find(scopestack[sp]);
        if(it!=symtables.end()){
            //已有符号表
            symtable=it->second;
            $2->varID=symtable->size()+1;
            symtable->insert(pair<int,Item*>($2->varID,item));
        }
        else{
            //新建符号表
            $2->varID=1;
            symtable=new map<int,Item*>;
            symtable->insert(pair<int,Item*>(1,item));
            symtables.insert(pair<int,map<int,Item*>*>(scopestack[sp],symtable));
        }
    }
    ;

decl
    : vardecl {$$=$1;}
    ;

vardecl
    : type ID {
        $$=new TreeNode($1->lineno, NODE_STMT);
        $$->stype = STMT_DECL;
        $$->addChild($1);
        $$->addChild($2);
        $2->type=$1->type;
        //添加符号表项
        $2->symtableID=scopestack[sp];
        item=new Item($2->var_name,$2->type);
        it=symtables.find(scopestack[sp]);
        if(it!=symtables.end()){
            //已有符号表
            symtable=it->second;
            $2->varID=symtable->size()+1;
            symtable->insert(pair<int,Item*>($2->varID,item));
        }
        else{
            //新建符号表
            $2->varID=1;
            symtable=new map<int,Item*>;
            symtable->insert(pair<int,Item*>(1,item));
            symtables.insert(pair<int,map<int,Item*>*>(scopestack[sp],symtable));
        }
    }
    | vardecl COMMA ID {
        $$=$1;
        $$->addChild($3);
        $3->type=$1->child->type;
        //添加符号表项
        $3->symtableID=scopestack[sp];
        item=new Item($3->var_name,$3->type);
        it=symtables.find(scopestack[sp]);
        if(it!=symtables.end()){
            //已有符号表
            symtable=it->second;
            $3->varID=symtable->size()+1;
            symtable->insert(pair<int,Item*>($3->varID,item));
        }
        else{
            //新建符号表
            $3->varID=1;
            symtable=new map<int,Item*>;
            symtable->insert(pair<int,Item*>(1,item));
            symtables.insert(pair<int,map<int,Item*>*>(scopestack[sp],symtable));
        }
    }
    ;

type
    : T_INT {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_INT;} 
    | T_CHAR {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_CHAR;}
    | T_BOOL {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_BOOL;}
    | T_STRING {$$=new TreeNode(lineno,NODE_TYPE); $$->type=TYPE_STRING;}
    | T_VOID {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_VOID;}
    ;


if_else
    : IF LPAREN expr_list RPAREN statement %prec LOWER_THEN_ELSE {
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_IF;
        $$->addChild($3);
        $$->addChild($5);
    }
    | IF LPAREN expr_list RPAREN statement ELSE statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_IF;
        $$->addChild($3);
        $$->addChild($5);
        $$->addChild($7);
    }
    ;

while
    : WHILE LPAREN expr_list RPAREN statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_WHILE;
        $$->addChild($3);
        $$->addChild($5);
    }
    ;

for
    : FOR LPAREN statement statement expr_list RPAREN statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_FOR;
        $$->addChild($3);
        $$->addChild($4);
        $$->addChild($5);
        $$->addChild($7);
    }
    ;

printf
    : PRINTF LPAREN expr_list RPAREN{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_PRINTF;
        $$->addChild($3);
    }
    ;

scanf
    : SCANF LPAREN expr_list RPAREN{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_SCANF;
        $$->addChild($3);
    }
    ;

expr_list
    : expr {$$=$1;}
    | expr_list COMMA expr {$$=$1; $$->addSibling($3);}
    ;

expr
    : assignment {$$=$1;}
    | BOOL{$$=$1;}
    | ID {
        $$=$1;
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
    }
    | INT {$$=$1;}
    | CHAR {$$=$1;}
    | STRING {$$=$1;}
    | expr MUL expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_MUL;
        $$->type=TYPE_INT;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr DIV expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_DIV;
        $$->type=TYPE_INT;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr MOD expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_MOD;
        $$->type=TYPE_INT;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr ADD expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_ADD;
        $$->type=TYPE_INT;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr SUB expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_SUB;
        $$->type=TYPE_INT;
        $$->addChild($1);
        $$->addChild($3);
    }
    | ADD expr %prec UPLUS {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_ADD;
        $$->type=TYPE_INT;
        $$->addChild($2);
    }
    | SUB expr %prec UMINUS {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_SUB;
        $$->type=TYPE_INT;
        $$->addChild($2);
    }
    | INC expr {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_PRE_INC;
        $$->type=$2->type;
        $$->addChild($2);
    }
    | DEC expr {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_PRE_DEC;
        $$->type=$2->type;
        $$->addChild($2);
    }
    | expr INC %prec POST_INC{
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_POS_INC;
        $$->type=$1->type;
        $$->addChild($1);
    }
    | expr DEC %prec POST_DEC{
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_POS_DEC;
        $$->type=$1->type;
        $$->addChild($1);
    }
    | expr GT expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_GT;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr LT expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_LT;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr GE expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_GE;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr LE expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_LE;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr EQ expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_EQ;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr NE expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_NE;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr AND expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_AND;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | expr OR expr{
        $$=new TreeNode($1->lineno,NODE_EXPR);
        $$->optype=OP_OR;
        $$->type=TYPE_BOOL;
        $$->addChild($1);
        $$->addChild($3);
    }
    | NOT expr {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_NOT;
        $$->type=TYPE_BOOL;
        $$->addChild($2);
    }
    | LPAREN expr RPAREN {$$=$2;}
    
    | ADDR ID {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_ADDR;
        $$->type=new Type(VALUE_ADDR);
        $$->addChild($2);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$2->var_name){
                    $2->type=iter->second->type;
                    $$->type->addChild($2->type);
                    $2->symtableID=scopestack[i];
                    $2->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        } 
    }
    ;

assignment
    : ID ASSIGN expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_ASSIGN;
        $$->addChild($1);
        $$->addChild($3);  
    }
    | ID ADD_ASSI expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_ADD_ASSI;
        $$->addChild($1);
        $$->addChild($3);
    }
    | ID SUB_ASSI expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_SUB_ASSI;
        $$->addChild($1);
        $$->addChild($3);
    }
    | ID MUL_ASSI expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_MUL_ASSI;
        $$->addChild($1);
        $$->addChild($3);
    }
    | ID DIV_ASSI expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_DIV_ASSI;
        $$->addChild($1);
        $$->addChild($3);
    }
    | ID MOD_ASSI expr{
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            it=symtables.find(scopestack[i]);
            if(it==symtables.end())
                continue;
            symtable=it->second;
            iter=symtable->rbegin();
            while(iter!=symtable->rend()){
                if(iter->second->name==$1->var_name){
                    $1->type=iter->second->type;
                    $1->symtableID=scopestack[i];
                    $1->varID=iter->first;
                    i=-1;
                    break;
                }
                iter++;
            }
        }
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_MOD_ASSI;
        $$->addChild($1);
        $$->addChild($3);
    }
    ;

%%

int yyerror(char const* message){
  cout << message << " at line " << lineno << endl;
  return -1;
}   