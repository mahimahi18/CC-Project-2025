%{
#include <stdio.h>
#include <string.h>
int u_cnt(const char *str) {
    int cnt = 0;
    while (*str) { if (*str == '_') cnt++; str++; }
    return cnt;
}
const char* keywords[] = {"int", "char", "if", "else", "while", "for", "main", "begin", "end", "print", "scan", "program", "VarDecl", "inc", "dec"};
%}

keyword [int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec]
var_name [a-z][a-z0-9_]*

%%
{var_name} { 
     for (int i = 0; i < 15; i++) {
        if (strcmp(yytext, keywords[i]) == 0) {printf("Error: '%s' is a keyword and cannot be used as a variable name.\n", yytext); return 0;}
     }
    if(u_cnt(yytext) <= 1) {printf("Valid variable name!\n"); return 0;}
    else {printf("Invalid variable name encountered.\n"); return 0;}
}
.|\n {printf("Invalid variable name encountered.\n"); return 0;}
%%

int main() {
    printf("Enter a variable name: ");
    yylex();
    return 0;
}


