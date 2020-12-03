#include "common.h"

extern TreeNode *root;
extern int yyparse();
extern int NODEID;
extern int yydebug;

int main(){
    //yydebug=1;  //open yacc debug
    yyparse();
    NODEID=0;
    if(root) {
        root->genNodeId();
        root->printAST();
    }
    return 0;
}