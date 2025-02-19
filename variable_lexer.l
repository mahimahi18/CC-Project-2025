%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int u_cnt(const char *str) {
    int cnt = 0;
    while (*str) { if (*str == '_') cnt++; str++; }
    return cnt;
}

const char* keywords[] = {"int", "char", "if", "else", "while", "for", "main", "begin", "end", "print", "scan", "program", "VarDecl", "inc", "dec"};
int vardecl = 0;
int vartype = 0;
int is_keyword = 0;
%}

keyword (int|char)
var_name [_a-z][_a-z0-9]*  
SEPARATOR   [:()\.,;{}\\"]

%%
"begin VarDecl" {
    vardecl = 1;
    printf("begin\tKeyword\n");
    printf("VarDecl\tKeyword\n");
}

"end VarDecl" {
    vardecl = 0;
    printf("end\tKeyword\n");
    printf("VarDecl\tKeyword\n");
}

{SEPARATOR} {
    if (vardecl) {
        printf("%s\tSeparator\n", yytext);
        if (strcmp(yytext, ",") == 0) vartype = 1; 
    }
}

{var_name} {
    if (vardecl) {
        if (vartype) {  
            vartype = 0;
            if (strcmp(yytext, "int") == 0 || strcmp(yytext, "char") == 0)	printf("%s\tKeyword\n", yytext);
            else   printf("%s\tError: Variable type can only be 'int' or 'char'\n", yytext);
          }
        else {  
            for (int i = 0; i < 15; i++) {
                if (strcmp(yytext, keywords[i]) == 0){
                printf("%s\tError: Keyword cannot be used as an identifier\n", yytext);
                is_keyword = 1;
                }
            }
            if (u_cnt(yytext) <= 1 && !is_keyword) 	printf("%s\tIdentifier\n", yytext);
            else if(!is_keyword)	printf("%s\tError: Invalid identifier '%s'\n", yytext, yytext);
        }
    }
}

.|\n {}

%%

int main() {
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        perror("input.txt");
        return 1;
    }

    printf("LEXEME\tTOKEN TYPE\n");
    yylex();
    fclose(yyin);
    return 0;
}

