%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// op_stage: 0 = expecting first operand, 1 = first operand read (expect operator),
// 2 = operator read (expect second operand)

int op_stage = 0;
int operand1, operand2;
int base1, base2;
char current_arith_op;

// Forward declarations of helper functions
int convertLiteralToDecimal(int literal, int base);
void convertDecimalToTargetBase(int decimalVal, int base, char *resultBuf);
void perform_arithmetic();

void print_token(const char* type, const char* value) {
    printf("<%s, %s>\n", type, value);
}
%}


INTCONST    \([0-9]+,[ ]*(10|8|2)\)

ARITH_OP    [+\-*/%]
REL_OP      "="|"<"|">"|"<="|">="|"<>" 
ASSIGN_OP   ":="|"\+="|"-="|"*="|"/="|"%="
SEPARATOR   [\(\),;{}\\"@]

%%

{INTCONST} {
    // Extract the numeric literal and base
    int num, b;
    sscanf(yytext, "(%d, %d)", &num, &b);
    
    // Print the token for the integer constant
    print_token("INTEGER_CONSTANT", yytext);
    
    if(op_stage == 0) {
        operand1 = num;
        base1 = b;
        op_stage = 1;  // now expecting an operator (if any)
    } else if(op_stage == 2) {
        operand2 = num;
        base2 = b;
        perform_arithmetic();
        op_stage = 0;  // Reset for next expression
    }
}


{ARITH_OP} {
    // For arithmetic operators, if we are in the correct state, store operator and move to next state.
    if(op_stage == 1) {
        current_arith_op = yytext[0];
        print_token("ARITHMETIC_OPERATOR", yytext);
        op_stage = 2;  // now expecting the second operand
    } else {
        // Otherwise, just print token
        print_token("ARITHMETIC_OPERATOR", yytext);
    }
}


{REL_OP} {
    print_token("RELATIONAL_OPERATOR", yytext);
}


{ASSIGN_OP} {
    print_token("ASSIGNMENT_OPERATOR", yytext);
}


{SEPARATOR} {
    print_token("SEPARATOR", yytext);
}


[ \t\n]+   {  }


. {
    printf("INVALID TOKEN: %s\n", yytext);
}

%%

int convertLiteralToDecimal(int literal, int base) {
    int decVal = 0;
    int multiplier = 1;
    while(literal > 0) {
        int digit = literal % 10;
        decVal += digit * multiplier;
        multiplier *= base;
        literal /= 10;
    }
    return decVal;
}


void convertDecimalToTargetBase(int decimalVal, int base, char *resultBuf) {
    if(base == 10) {
        sprintf(resultBuf, "%d", decimalVal);
    } else if(base == 8) {
        sprintf(resultBuf, "%o", decimalVal);
    } else if(base == 2) {
        char temp[33];
        int index = 0;
        if(decimalVal == 0) {
            strcpy(resultBuf, "0");
            return;
        }
        while(decimalVal > 0) {
            temp[index++] = (decimalVal % 2) + '0';
            decimalVal /= 2;
        }
        temp[index] = '\0';
        // Reverse
        int len = index;
        for(int i = 0; i < len; i++) {
            resultBuf[i] = temp[len - i - 1];
        }
        resultBuf[len] = '\0';
    }
}


void perform_arithmetic() {
    int decOp1 = convertLiteralToDecimal(operand1, base1);
    int decOp2 = convertLiteralToDecimal(operand2, base2);
    int targetBase;
    
    // Determine target base (highest precedence)
    if(base1 == 10 || base2 == 10)
        targetBase = 10;
    else if(base1 == 8 || base2 == 8)
        targetBase = 8;
    else
        targetBase = 2;
    
    int decResult;
    switch(current_arith_op) {
        case '+': decResult = decOp1 + decOp2; break;
        case '-': decResult = decOp1 - decOp2; break;
        case '*': decResult = decOp1 * decOp2; break;
        case '/': 
            if(decOp2 == 0) {
                printf("ERROR: Division by zero.\n");
                return;
            }
            decResult = decOp1 / decOp2; break;
        case '%': 
            if(decOp2 == 0) {
                printf("ERROR: Modulo division by zero.\n");
                return;
            }
            decResult = decOp1 % decOp2; break;
        default:
            printf("ERROR: Unknown operator %c\n", current_arith_op);
            return;
    }
    
    char convertedResult[50];
    convertDecimalToTargetBase(decResult, targetBase, convertedResult);
    
    printf("ARITHMETIC RESULT: (%s, %d)\n", convertedResult, targetBase);
}

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
