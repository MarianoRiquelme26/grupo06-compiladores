%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"


// VARIABLES REQUERIDAS //
FILE *yyin;

//int yylval;
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
TEXT_W			{COMILLA}.{TEXT}+.{COMILLA}
COMENTARIO		{COM_ABRE}.{TEXT}+.{COM_CIERRA}
OP_MUL			[*]
RES				[-]

/*
	FALTA AGREGAR TODOS LOS CARACTERES ESEPECIALES
*/

%%

{MAX}			{printf("operacion maximo: %s\n",yytext);return MAX;}
{PUT}			{printf("put: %s\n",yytext);return PUT;}
{AS}			{printf("AS: %s\n",yytext);return AS;}
{DIM}			{printf("DIM: %s\n",yytext);return DIM;}
{AND}			{printf("arega condicion: %s\n",yytext);return AND;}
{OR}			{printf("arega condicion: %s\n",yytext);return OR;}
{GET}			{printf("get: %s\n",yytext);return GET;}
{IF}			{printf("inicio di condicionl: %s\n",yytext);return IF;}
{ELSE}			{printf("caso falso condicional: %s\n",yytext);return ELSE;}
{WHILE}			{printf("Iteracion: %s\n",yytext);return WHILE;}
{LLAVE_I}		{printf("Apertura de llave: %s\n",yytext);return LLAVE_I;}
{LLAVE_F}		{printf("Cierre de llave: %s\n",yytext);return LLAVE_F;}
{OP_SUM}		{printf("Suma: %s\n",yytext);return OP_SUM;}
{PAR_I}			{printf("Apertura de parentesis: %s\n",yytext);return PAR_I;}
{PAR_F}			{printf("Cierre de parentesis: %s\n",yytext);return PAR_F;}
{OP_AS}			{printf("Asignacion: %s\n",yytext);return OP_AS;}
{DIV}			{printf("Division: %s\n",yytext);return DIV;}
{RES}			{printf("Resta: %s\n",yytext);return RES;}
{MAYOR}			{printf("Condicional %s\n",yytext);return MAYOR;}
{MENOR}			{printf("Condicional %s\n",yytext);return MENOR;}
{IGUAL}			{printf("Condicional %s\n",yytext);return IGUAL;}
{MAYOR_IGUAL}	{printf("Condicional %s\n",yytext);return MAYOR_IGUAL;}
{MENOR_IGUAL}	{printf("Condicional %s\n",yytext);return MENOR_IGUAL;}
{INTEGER}		{printf("Integer: %s\n",yytext);return INTEGER;}
{FLOAT}			{printf("Float: %s\n",yytext);return FLOAT;}
{STRING}		{printf("String: %s\n",yytext);return STRING;}
{ID}			{
					printf("Identificador: %s\n",yytext);
					yylval.stringValue = strdup(yytext); 
					return ID;
				}
{FIN_SENT}		{printf("Fin sentencia: %s\n",yytext);return FIN_SENT;}
{SEPARADOR}		{printf("Separador de variables: %s\n",yytext);return SEPARADOR;}
{CTE_ENT}		{
					if(atoi(yytext)<=65535)
					{
						printf("Constante entera: %s\n",yytext);
						yylval.stringValue = strdup(yytext); 
					return CTE_ENT;
					}
					else {
					printf("Error - supero el limite de la variable: %s\n",yytext);
					}
					
				}
{CTE_REAL}		{
					if(atof(yytext)>=-3.40282347e+38F && atof(yytext)<=3.40282347e+38F)
					{
						printf("Constante en real: %s\n",yytext);
						yylval.stringValue = strdup(yytext); 
					return CTE_REAL;
					}
					else {
					printf("ERROR - Fue superado el maximo para la veriable real\n"); 
					}
					
				}

{CTE_HEX}		{
					printf("Constante en hexa: %s\n",yytext);
					yylval.stringValue = strdup(yytext); 
					return CTE_HEX;
				}	
{CTE_OC}		{
					printf("Constante en octal: %s\n",yytext);
					yylval.stringValue = strdup(yytext); 
					return CTE_OC;
				}	
				
{CTE_BIN}		{
					printf("Constante en binario: %s\n",yytext);
					yylval.stringValue = strdup(yytext); 
					return CTE_BIN;
				}
				
{COMILLA}		{printf("Comilla: %s\n",yytext);return COMILLA;}
{TEXT_W}		{if(strlen(yytext) <= 50){
					printf("Texto por consola: %s\n",yytext);
					return TEXT_W;
			     } else {
			        printf("ERROR - Salida muy larga, no debe superar los 40 caracteres\n"); 
				 }
				}
{OP_MUL}		{printf("Multiplicacion: %s\n",yytext);return OP_MUL;}
{COMENTARIO}	{printf("Esto es un comentario : %s\n",yytext);return COMENTARIO;}
{MAYOR_IGUAL}	{printf("Simbolo logico: %s\n",yytext);return MAYOR_IGUAL;}
{MENOR_IGUAL}	{printf("Simbolo logico: %s\n",yytext);return MENOR_IGUAL;}
{DISTINTO}		{printf("Simbolo logico: %s\n",yytext);return DISTINTO;}
{ASIG}			{printf("Asignacion: %s\n",yytext);return ASIG;}
{NOT}			{printf("NOt: %s\n",yytext);return NOT;}


"\n"
"\t"
.
%%
