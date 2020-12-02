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
%right NOT
%right UPLUS UMINUS

%%
program
    : statements {
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
    | declaration SEMICOLON {$$=$1;}
    | if_else {$$=$1;}
    | while {$$=$1;}
    | for {$$=$1;}
    | assignment SEMICOLON {$$=$1;}
    | printf SEMICOLON {$$=$1;}
    | scanf SEMICOLON {$$=$1;}
    | LBRACE statements RBRACE {$$=$2;}
    | RETURN expr SEMICOLON {
        $$=new TreeNode(lineno, NODE_STMT);
        $$->stype = STMT_RETURN;
        $$->addChild($2);
    }
    ;

declaration
    : type ID ASSIGN expr{
        $$=new TreeNode($1->lineno, NODE_STMT);
        $$->stype = STMT_DECL;
        $$->addChild($1);
        $$->addChild($2);
        $$->addChild($4);
        $2->type=$1->type;
        $2->symtableID=scopestack[sp];
        $2->varID=++symbolnum;
        item=new Item($2->var_name,$1->type);
        if(symbolnum==1){
            //创建符号表
            symtable=new map<int,Item*>;
            symtable->insert(pair<int,Item*>(symbolnum,item));
            symtables.insert(pair<int,map<int,Item*>*>(scopestack[sp],symtable));
        }
        else{
            //插入到对应作用域的符号表
            symtable=symtables.find(scopestack[sp])->second;
            symtable->insert(pair<int,Item*>(symbolnum,item));
        }
    } 
    | type ID {
        $$=new TreeNode($1->lineno, NODE_STMT);
        $$->stype = STMT_DECL;
        $$->addChild($1);
        $$->addChild($2);
        $2->type=$1->type;
        $2->symtableID=scopestack[sp];
        $2->varID=++symbolnum;
        item=new Item($2->var_name,$1->type);
        if(symbolnum==1){
            //创建符号表
            symtable=new map<int,Item*>;
            symtable->insert(pair<int,Item*>(symbolnum,item));
            symtables.insert(pair<int,map<int,Item*>*>(scopestack[sp],symtable));
        }
        else{
            //插入到对应作用域的符号表
            symtable=symtables.find(scopestack[sp])->second;
            symtable->insert(pair<int,Item*>(symbolnum,item));
        }
    }
    ;

type
    : T_INT {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_INT;} 
    | T_CHAR {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_CHAR;}
    | T_BOOL {$$ = new TreeNode(lineno, NODE_TYPE); $$->type = TYPE_BOOL;}
    | T_STRING {$$=new TreeNode(lineno,NODE_TYPE); $$->type=TYPE_STRING;}
    ;


if_else
    : IF LPAREN expr RPAREN statement %prec LOWER_THEN_ELSE {
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_IF;
        $$->addChild($3);
        $$->addChild($5);
    }
    | IF LPAREN expr RPAREN statement ELSE statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_IF;
        $$->addChild($3);
        $$->addChild($5);
        $$->addChild($7);
    }
    ;

while
    : WHILE LPAREN expr RPAREN statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_WHILE;
        $$->addChild($3);
        $$->addChild($5);
    }
    ;

for
    : FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN statement{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_FOR;
        $$->addChild($3);
        $$->addChild($5);
        $$->addChild($7);
        $$->addChild($9);
    }
    ;

assignment
    : ID ASSIGN expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_ASSIGN;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | ID ADD_ASSI expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_ADD_ASSI;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | ID SUB_ASSI expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_SUB_ASSI;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | ID MUL_ASSI expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_MUL_ASSI;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | ID DIV_ASSI expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_DIV_ASSI;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | ID MOD_ASSI expr{
        $$=new TreeNode($1->lineno,NODE_STMT);
        $$->stype=STMT_ASSI;
        $$->optype=OP_MOD_ASSI;
        $$->addChild($1);
        $$->addChild($3);
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    ;

printf
    : PRINTF LPAREN expr RPAREN{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_PRINTF;
        $$->addChild($3);
    }
    ;

scanf
    : SCANF LPAREN expr RPAREN{
        $$=new TreeNode(lineno,NODE_STMT);
        $$->stype=STMT_SCANF;
        $$->addChild($3);
    }
    ;

expr
    : BOOL{$$=$1;}
    | ID {
        $$=$1;
        //查找所有有效作用域的符号表中有无该符号
        for(int i=sp;i>=0;i--){
            symtable=symtables.find(scopestack[i])->second;
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
    | NOT expr {
        $$=new TreeNode(lineno,NODE_EXPR);
        $$->optype=OP_NOT;
        $$->type=TYPE_BOOL;
        $$->addChild($2);
    }
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
    | LPAREN expr RPAREN {$$=$2;}
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
    ;



%%

int yyerror(char const* message){
  cout << message << " at line " << lineno << endl;
  return -1;
}   