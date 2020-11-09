%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include "files_h/constantes.h"
#include "files_h/ts.h"

FILE *yyin;
char *yyltext;


%}
%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
LETRA_HEXA		{DIGITO}|[a-fA-F]
INTEGER         "Integer"
FLOAT 			"Float"
STRING 			"String"
DIM 	        "DIM"
AS 				"AS"
WHILE			"WHILE"|"while"
AND 			"AND"|"and"
OR              "OR"
NOT 			"NOT"
IF              "IF"|"if"
MAX				"MAXIMO"|"maximo"
ELSE			"ELSE"|"else"|"Else"
ASIG			":="|"="
PUT			    "PUT"
GET			    "GET"
PAR_I			"("
PAR_F			")"
LLAVE_I			"{"
LLAVE_F			"}"
OP_AS			":"
OP_SUM			"+"
COM_ABRE		"*-"
COM_CIERRA      "-*"
DIV				"/"
FIN_SENT		";"
SEPARADOR		","
ESP				" "
MAYOR  			">"
MENOR  			"<"
IGUAL		 	"=="
MAYOR_IGUAL 	">="
MENOR_IGUAL 	"<="
DISTINTO  		"!="|"<>"	
COMILLA			["]
CTE_ENT			{DIGITO}+
CTE_REAL		{CTE_ENT}*"."{DIGITO}*
CTE_HEX			"0x"{LETRA_HEXA}+
CTE_OC			"0o".{DIGITO}*
CTE_BIN			"0b".{DIGITO}*
ID				{LETRA}+{DIGITO}*
TEXT			{LETRA}*.{ESP}*.{OP_AS}*.{CTE_ENT}*.{ESP}*
CARACTER		[a-z,A-Z,0-9,=,>,<,!,:,+,-,*,/]
ESPACIO         [" "]        
CTE_STR			{COMILLA}({CARACTER}+|{ESPACIO})*{COMILLA} 
COMENTARIO		{COM_ABRE}.{TEXT}+.{COM_CIERRA}
OP_MUL			[*]
RES				[-]

%%

{MAX}			{return MAX;}
{PUT}			{return PUT;}
{AS}			{return AS;}
{DIM}			{return DIM;}
{AND}			{return AND;}
{OR}			{return OR;}
{GET}			{return GET;}
{IF}			{return IF;}
{ELSE}			{return ELSE;}
{WHILE}			{return WHILE;}
{LLAVE_I}		{return LLAVE_I;}
{LLAVE_F}		{return LLAVE_F;}
{OP_SUM}		{return OP_SUM;}
{PAR_I}			{return PAR_I;}
{PAR_F}			{return PAR_F;}
{OP_AS}			{return OP_AS;}
{DIV}			{return DIV;}
{RES}			{return RES;}
{MAYOR}			{return MAYOR;}
{MENOR}			{return MENOR;}
{IGUAL}			{return IGUAL;}
{MAYOR_IGUAL}	{return MAYOR_IGUAL;}
{MENOR_IGUAL}	{return MENOR_IGUAL;}
{INTEGER}		{return INTEGER;}
{FLOAT}			{return FLOAT;}
{STRING}		{return STRING;}
{ID}			{
					yylval.stringValue = strdup(yytext); 
					return ID;
				}
{FIN_SENT}		{return FIN_SENT;}
{SEPARADOR}		{return SEPARADOR;}
{CTE_ENT}		{
					if(atoi(yytext)<=65535 && atoi(yytext)>=-65535)
					{
						
					yylval.stringValue = strdup(yytext);
					insertarTokenEnTS("CTE_ENT", yylval.stringValue);					
					return CTE_ENT;
					}
					else {
					printf("lexico: Error - supero el limite de la variable %s\n",yytext);
					}
					
				}
{CTE_REAL}		{
					if(atof(yytext)>=-3.40282347e+38F && atof(yytext)<=3.40282347e+38F)
					{
					yylval.stringValue = strdup(yytext); 
					insertarTokenEnTS("CTE_REAL", yylval.stringValue);
					return CTE_REAL;
					}
					else {
					printf("lexico: ERROR - Fue superado el maximo para la veriable real %s\n",yytext); 
					}
					
				}

{CTE_HEX}		{
					yylval.stringValue = strdup(yytext);
					//insertarTokenEnTS("CTE_HEX", yylval.stringValue);					
					return CTE_HEX;
				}	
{CTE_OC}		{
					yylval.stringValue = strdup(yytext);
					//insertarTokenEnTS("CTE_OC", yylval.stringValue);					
					return CTE_OC;
				}	
				
{CTE_BIN}		{
					yylval.stringValue = strdup(yytext);
					//insertarTokenEnTS("CTE_BIN", yylval.stringValue);					
					return CTE_BIN;
				}
				
{COMILLA}		{return COMILLA;}
{CTE_STR}		{if(strlen(yytext) <= 30){
					memcpy(yytext, &yytext[1], strlen(yytext)-2);
                    yytext[strlen(yytext)-2] = '\0';
                    sprintf(yylval.stringValue,"_%s",yytext);
					insertarTokenEnTS("CTE_STR", yylval.stringValue);
					return CTE_STR;
			     } else {
			        printf("lexico: ERROR - Salida muy larga, no debe superar los 30 caracteres %s\n",yytext); 
				 }
				}
{OP_MUL}		{return OP_MUL;}
{COMENTARIO}	{return COMENTARIO;}
{MAYOR_IGUAL}	{return MAYOR_IGUAL;}
{MENOR_IGUAL}	{return MENOR_IGUAL;}
{DISTINTO}		{return DISTINTO;}
{ASIG}			{return ASIG;}
{NOT}			{return NOT;}

"\n"
"\t"
.
%%
