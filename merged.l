%{
#include <stdio.h>
#include <stdlib.h>
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


void print_token(const char* type, const char* value) {
    printf("%s\t%s\n", value, type);
}

int validate_integer_constant(const char *numStr, int base) {
    for (int i = 0; numStr[i] != '\0'; i++) {
        char c = numStr[i];
        if (base == 2) {
            if (c != '0' && c != '1')
                return 0;
        } else if (base == 8) {
            if (c < '0' || c > '7')
                return 0;
        } else if (base == 10) {
            if (c < '0' || c > '9')
                return 0;
        } else {
            return 0;
        }
    }
    return 1;
}
%}

keyword (int|char)
var_name [_a-z][_a-z0-9]*  
INTCONST    \([0-9]+,[ ]*(10|8|2)\)
ARITH_OP    [+\-*/%]
REL_OP      "<"|">"|"<="|">="|"<>" 
ASSIGN_OP   ":="|"\\+="|"-="|"*="|"/="|"%="
SEPARATOR   [:()\.,;{}\\"]

%%

"begin VarDecl" {
    vardecl = 1;
    print_token("Keyword", "begin");
    print_token("Keyword", "VarDecl");
}

"end VarDecl" {
    vardecl = 0;
    print_token("Keyword", "end");
    print_token("Keyword", "VarDecl");
}

{SEPARATOR} {
    print_token("SEPARATOR", yytext);
    if (vardecl && strcmp(yytext, ",") == 0) vartype = 1; 
}

{var_name} {
    if (vardecl) {
        if (vartype) {  
            vartype = 0;
            if (strcmp(yytext, "int") == 0 || strcmp(yytext, "char") == 0)
                print_token("Keyword", yytext);
            else
                printf("%s\tError: Variable type can only be 'int' or 'char'\n", yytext);
        } else {  
            for (int i = 0; i < 15; i++) {
                if (strcmp(yytext, keywords[i]) == 0){
                    printf("%s\tError: Keyword cannot be used as an identifier\n", yytext);
                    is_keyword = 1;
                }
            }
            if (u_cnt(yytext) <= 1 && !is_keyword)
                print_token("Identifier", yytext);
            else if(!is_keyword)
                printf("%s\tError: Invalid identifier '%s'\n", yytext, yytext);
        }
    }
}

{INTCONST} {
    char numStr[100];
    int base;
    int count = sscanf(yytext, "(%[^,],%d)", numStr, &base);
    if (count == 2) {
        if (base != 10 && base != 8 && base != 2) {
            printf("%s\tError: invalid integer constant (invalid base)\n", yytext);
        } else if (!validate_integer_constant(numStr, base)) {
            printf("%s\tError: invalid integer constant\n", yytext);
        } else {
            print_token("Integer constant", yytext);
        }
    } else {
        printf("%s\tError: invalid integer constant format\n", yytext);
    }
    
}

{ARITH_OP} {
    print_token("ARITHMETIC_OPERATOR", yytext);
}

{REL_OP} {
    print_token("RELATIONAL_OPERATOR", yytext);
}

{ASSIGN_OP} {
    print_token("ASSIGNMENT_OPERATOR", yytext);
}

[ \t\n]+ { }

. { }

%%

int main() {
    yyin = fopen("testinput.txt", "r");
    if (!yyin) {
        perror("testinput.txt");
        return 1;
    }
    printf("LEXEME\tTOKEN TYPE\n");
    yylex();
    fclose(yyin);
    return 0;
}

int yywrap() {
    return 1;
}
