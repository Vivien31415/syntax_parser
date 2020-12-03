%option nounput
%{
#include "common.h"
#include "main.tab.h"

int lineno=1;       //行号

%}

BLOCKCOMMENT \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT \/\/[^\n]*
EOL	(\r\n|\n)
WHITE [ \t]
INT [0-9]+
CHAR \'.?\'
STRING \".+\"
ID [[:alpha:]_][[:alpha:][:digit:]_]*
%%

{BLOCKCOMMENT} {
    unsigned int i=0,line=0;
    for(;i<strlen(yytext);i++){
        if(yytext[i]=='\n')
            line++;
    }
    lineno+=line;
}
{LINECOMMENT}  /* do nothing */

"int" return T_INT;
"void" return T_VOID;
"bool" return T_BOOL;
"char" return T_CHAR;
"string" return T_STRING;

"if" return IF;
"while" return WHILE;
"else" return ELSE;
"for" return FOR;
"printf" return PRINTF;
"scanf" return SCANF;
"return" return RETURN;

"=" return ASSIGN;
"+" return ADD;
"-" return SUB;
"*" return MUL;
"/" return DIV;
"%" return MOD;
"++" return INC;
"--" return DEC;
"+=" return ADD_ASSI;
"-=" return SUB_ASSI;
"*=" return MUL_ASSI;
"/=" return DIV_ASSI;
"%=" return MOD_ASSI;
"==" return EQ;
">" return GT;
"<" return LT;
">=" return GE;
"<=" return LE;
"!=" return NE;
"&&" return AND;
"||" return OR;
"!" return NOT;
"&" return ADDR;
";" return SEMICOLON;
"," return COMMA;
"(" return LPAREN;
")" return RPAREN;
"{" {
    scopestack[++sp]=scopenum++;
    return LBRACE;
}
"}" {
    --sp;
    return RBRACE;
}
"[" return LBRACKET;
"]" return RBRACKET;

"true" {
    TreeNode *node = new TreeNode(lineno,NODE_CONST);
    node->type=TYPE_BOOL;
    node->b_val = true;
    yylval = node;
    return BOOL;
}
"false" {
    TreeNode *node = new TreeNode(lineno,NODE_CONST);
    node->type=TYPE_BOOL;
    node->b_val = false;
    yylval = node;
    return BOOL;
}
{INT} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_INT;
    node->int_val = atoi(yytext);
    yylval = node;
    return INT;
}

{CHAR} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_CHAR;
    node->ch_val = yytext[1];
    yylval = node;
    return CHAR;
}

{STRING} {
    TreeNode* node = new TreeNode(lineno, NODE_CONST);
    node->type = TYPE_STRING;
    node->str_val = string(yytext);
    yylval = node;
    return STRING;
}

{ID} {
    TreeNode* node = new TreeNode(lineno, NODE_VAR);
    node->var_name = string(yytext);
    node->varID=0;
    node->symtableID=-1;
    yylval = node;
    return ID;
}

{WHITE} /* do nothing */

{EOL} lineno++;

. {
    cerr << "[line "<< lineno <<" ] unknown character:" << yytext << endl;
}
%%