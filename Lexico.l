%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;
int yylval;
char *yyltext;

%}
%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
LETRA_HEXA		[a-f,A-F,0-9]	
CTE_ENT			{DIGITO}+
CTE_REAL		{CTE_ENT}*"."{DIGITO}*
CTE_STRING		\"(({LETRA}|{DIGITO}|[\?\¿\!\¡=#$%()\[\]{}_-]){0,30})\"
CTE_HEX			"0x"{LETRA_HEXA}+
CTE_OC			"0o".{DIGITO}*
CTE_BIN			"0b".{DIGITO}*
ID				{LETRA}({LETRA}|{DIGITO}|_)*
TEXTO			(({LETRA}|{DIGITO}|[\?\¿\!\¡=#$%()\[\]{}_-]))
COMENTARIO		"*-".{TEXTO}+."-*"

%%

"PUT"			{return PUT;}
"AS"			{return AS;}
"DIM"			{return DIM;}
"GET"			{return GET;}
"if"			{return IF;}
"Else"			{return ELSE;}
"while"			{return WHILE;}
"{"				{return LLAVE_I;}
"}"				{return LLAVE_F;}
"["				{return CORCHETE_I;}
"]"				{return CORCHETE_F;}
"+"				{return OP_SUM;}
"-"				{return OP_RES;}
"*"				{return OP_MULT;}
"/"				{return OP_DIV;}
"("				{return PAR_I;}
")"				{return PAR_F;}
":="			{return OP_AS;}
">"				{return MAYOR;}
"<"				{return MENOR;}
"=="			{return COMPARACION;}
">="			{return MAYOR_IGUAL;}
"<="			{return MENOR_IGUAL;}
"<>"			{return DISTINTO;}
"Integer"		{return INTEGER;}
"Float"			{return FLOAT;}
"String"		{return STRING;}
";"				{return FIN_SENT;}
","				{return COMA;}
" "				{return ESPACIO;}
"				{return COMILLA;}
"||"            {return OPER_OR;}
"&&" 			{return OPER_AND;}
"!" 			{return OPER_NOT;}
"maximo" 		{return MAXIMO;}

{ID}			{
					printf("Identificador: %s\n",yytext);
					yylval.str_val = strdup(yytext);
					return ID;
					
				}
{CTE_ENT}		{
					if(atoi(yytext)<=65535)
					{
						printf("Constante entera: %s\n",yytext);
						yylval.int_val = strdup(yytext);
						return CTE_ENT;
					
					}
					else {
					printf("Se supera el limite permitido para integer: %s\n",yytext);
					}
					
				}
{CTE_REAL}   	{if(atof(yytext)>=-3.40282347e+38F && atof(yytext)<=3.40282347e+38F){
					printf("Constante en real: %s\n",yytext);
					yylval.real_val = strdup(yytext);
					return CTE_REAL;
					
			     } else {
			           	printf("Se supera el limite permitido para real\n"); 
				 }
				}
{CTE_STRING}		{if(strlen(yytext) <= 40){
						printf("Texto por consola: %s\n",yytext);
						yylval.str_val = strdup(yytext);
						return CTE_STRING;
						
			     } else {
			           	printf("Se supera el limite permitido para un string\n"); 
				 }
				}
{CTE_HEX}		{return CTE_HEX;}
{CTE_OC}		{return CTE_OC;}
{CTE_BIN}		{return CTE_BIN;}
				
"\n"
" "
"\t"

%%

int main (int argc,char *argv[]){
	
 if ((yyin=fopen(argv[1],"rt"))==NULL){
 
  	printf("\n No se puede abrir el archivo: %s\n",argv[1]);
}
 else{
	yylex();
}
	fclose(yyin);
	return 0;
}

int yyerror(void){
 
 	  printf("Syntax Error\n");
	  system("Pause");
      exit (1);
}

