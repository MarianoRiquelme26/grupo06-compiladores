%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    char token[3];
    char lexema[10];
} t_info;
typedef struct s_nodo_lista
{
    t_info dat;
    struct s_nodo_lista* sig;
} t_nodo_lista;
typedef t_nodo_lista* t_lista;

typedef int (*t_cmp)(const void*,const void*);
    
int comp(const void* d1,const void *d2)
{
    t_info *dat1=(t_info*)d1;
    t_info *dat2=(t_info*)d2;
	return strcmp(dat1->lexema,dat2->lexema);
}


FILE *yyin;
int yylval;
char *yyltext;
t_lista lista1;
t_info dat;
//PRIMITIVAS DE LISTA
void listaCrear(t_lista* pl)
{
    *pl=NULL;
}
int listaVacia(const t_lista* pl)
{
    return !*pl;
}
void listaVaciar(t_lista* pl,t_info* dat)
{
    t_nodo_lista* elim;

    while(*pl)
    {
        elim=*pl;
		*dat=elim->dat;
		printf("token :%s\t%s\n",dat->token,dat->lexema);
        *pl=elim->sig;
        free(elim);
		
    }
}

int listaBuscar(const t_lista* pl,t_info* dat,t_cmp comp)
{
    while(*pl){
		if(comp(dat,&(*pl)->dat)==0)
		{printf("token :%s\t%s\n",dat->token,dat->lexema);
			return 1;
		}
		pl=&(*pl)->sig;
	}
    
    return 0;
}

int insertarLista(t_lista* pl,t_info* dat)
{
    t_nodo_lista* nuevo;

    nuevo=(t_nodo_lista*)malloc(sizeof(t_nodo_lista));
    if(!nuevo)
        return 0;
    nuevo->dat=*dat;
    nuevo->sig=*pl;
    *pl=nuevo;
    return 1;
}


////////////////////

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
COMPARACION 	"=="
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

{PUT}			printf("put: %s\n",yytext);
{AS}			printf("AS: %s\n",yytext);
{DIM}			printf("DIM: %s\n",yytext);
{AND}			printf("arega condicion: %s\n",yytext);
{GET}			printf("get: %s\n",yytext);
{IF}			printf("inicio di condicionl: %s\n",yytext);
{ELSE}			printf("caso falso condicional: %s\n",yytext);
{WHILE}			printf("Iteracion: %s\n",yytext);
{LLAVE_I}		printf("Apertura de llave: %s\n",yytext);
{LLAVE_F}		printf("Cierre de llave: %s\n",yytext);
{OP_SUM}		printf("Suma: %s\n",yytext);
{PAR_I}			printf("Apertura de parentesis: %s\n",yytext);
{PAR_F}			printf("Cierre de parentesis: %s\n",yytext);
{OP_AS}			printf("Asignacion: %s\n",yytext);
{DIV}			printf("Division: %s\n",yytext);
{RES}			printf("Resta: %s\n",yytext);
{MAYOR}			printf("Condicional %s\n",yytext);
{MENOR}			printf("Condicional %s\n",yytext);
{COMPARACION}	printf("Condicional %s\n",yytext);
{MAYOR_IGUAL}	printf("Condicional %s\n",yytext);
{MENOR_IGUAL}	printf("Condicional %s\n",yytext);
{DISTINTO}		printf("Condicional %s\n",yytext);
{INTEGER}		printf("Integer: %s\n",yytext);
{FLOAT}			printf("Float: %s\n",yytext);
{STRING}		printf("String: %s\n",yytext);
{ID}			{
					printf("Identificador: %s\n",yytext);
					strcpy(dat.token,"ID");
					strcpy(dat.lexema,yytext);
					if(!listaBuscar(&lista1,&dat,comp)){
						insertarLista(&lista1,&dat);
					}
					
				}
{FIN_SENT}		printf("Fin sentencia: %s\n",yytext);
{SEPARADOR}		printf("Separador de variables: %s\n",yytext);
{ESP}			printf("");
{CTE_ENT}		{
					if(atoi(yytext)<=65535)
					{
						printf("Constante entera: %s\n",yytext);
						strcpy(dat.token,"CTE");
						strcpy(dat.lexema,yytext);
						if(!listaBuscar(&lista1,&dat,comp)){
							insertarLista(&lista1,&dat);
						}
					
					}
					else {
					printf("Error - supero el limite de la variable: %s\n",yytext);
					}
					
				}
{CTE_REAL}   	{if(atof(yytext)>=-3.40282347e+38F && atof(yytext)<=3.40282347e+38F){
					printf("Constante en real: %s\n",yytext);
			     } else {
			           	printf("ERROR - Fue superado el maximo para la veriable real\n"); 
				 }
				}
{CTE_HEX}		printf("Constante en hexa: %s\n",yytext);
{CTE_OC}		printf("Constante en octal: %s\n",yytext);
{CTE_BIN}		printf("Constante en binario: %s\n",yytext);
{COMILLA}		printf("Comilla: %s\n",yytext);
{TEXT_W}		{if(strlen(yytext) <= 40){
					printf("Texto por consola: %s\n",yytext);
			     } else {
			           	printf("ERROR - Salida muy larga, no debe superar los 40 caracteres\n"); 
				 }
				}
{OP_MUL}		printf("Multiplicacion: %s\n",yytext);
{COMENTARIO}	printf("Esto es un comentario : %s\n",yytext);
{MAYOR}			printf("Simbolo logico: %s\n",yytext);
{MENOR}			printf("Simbolo logico: %s\n",yytext);
{COMPARACION}	printf("Simbolo logico: %s\n",yytext);
{MAYOR_IGUAL}	printf("Simbolo logico: %s\n",yytext);
{MENOR_IGUAL}	printf("Simbolo logico: %s\n",yytext);
{DISTINTO}		printf("Simbolo logico: %s\n",yytext);

"\n"
"\t"

%%

int main (int argc,char *argv[]){

 //creo la tabla de simbolos
 listaCrear(&lista1);
	
 if ((yyin=fopen(argv[1],"rt"))==NULL)
 {
  	printf("\nNo se puede abrir el archivo: %s\n",argv[1]);
 }
 else{
	yylex();
 }
 fclose(yyin);
 //vacio la tabla de simbolos
 printf("------------------------------------------\n");
 printf("-----TABLA DE SIMBOLOS--------------------\n");
 printf("------------------------------------------\n");
 listaVaciar(&lista1,&dat);
 return 0;
}
int yyerror(void)
	{ 
 	  printf("Syntax Error\n");
	  system("Pause");
          exit (1);
	}

