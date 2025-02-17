%{
#include <stdio.h>
%}

%%
'[a-z0-9]' {printf("Character Constant\n");}
\"[a-zA-Z0-9+\-/%*<>=_;,{}|\t ]*\" {printf("String Constant\n");}
(int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|dec) {printf("Keyword: %s\n", yytext);}

%%

int main() {
    // Open the sample file
    yyin = fopen("sample.txt", "r");

    // Start lexing the file
    yylex();
    return 0;
}
