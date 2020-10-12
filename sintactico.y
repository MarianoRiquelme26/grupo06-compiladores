%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
int yystopparser=0;
FILE *yyin;
int yyerror();
int yylex();
//int yylval;
char *yyltext;


// DEFICION DE ESTRUCTURA DE INFORMACION QUE VA CONTENER EL TOKEN Y LEXEMA //
typedef struct
{
    char token[4];
    char lexema[10];
} t_info;
// DEFINCION DE LA ESTRUCTURA DE LA LISTA //
typedef struct s_nodo_lista
{
    t_info dat;
    struct s_nodo_lista* sig;
} t_nodo_lista;
typedef t_nodo_lista* t_lista;

typedef int (*t_cmp)(const void*,const void*);
// FUNCION DE COMPARACION DE LEXEMAS //    
int comp(const void* d1,const void *d2)
{
    t_info *dat1=(t_info*)d1;
    t_info *dat2=(t_info*)d2;
	return strcmp(dat1->lexema,dat2->lexema);
}
t_lista lista1;
t_info dat;
int contadorLetrastID = 0;
int contadorLetrastCT = 0;
// PRIMITIVAS DE LISTA //
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
	FILE *pt;
    char* cad;
    char lineaID[contadorLetrastID+1];
	char lineaCTE[contadorLetrastCT+1];
	strcpy(lineaID,"");
	strcpy(lineaCTE,"");
    t_nodo_lista* elim;
	pt=fopen("MatrizDeSimbolos.txt","wt");
    if(!pt)
    {
        puts("erro al intentar abrir algun archivo");
        exit(0);
    }
	
    while(*pl)
    {
        elim=*pl;
		*dat=elim->dat;
		if(strcmp(dat->token,"ID")==0)
		{
			strcat(lineaID,",");
			strcat(lineaID,dat->lexema);
		}
			
		if(strcmp(dat->token,"CTE")==0)
		{
			strcat(lineaCTE,",");
			strcat(lineaCTE,dat->lexema);
		}
			
        *pl=elim->sig;
        free(elim);
		
    }
	//correcion para borrar la primer coma
	cad = lineaID;
	*cad = ' ';
	cad = lineaCTE;
	*cad = ' ';
	// guardo las lineas en la tabla de simbolos //
	fprintf(pt,"token: ID\t lexemas: %s\n",lineaID);
	fprintf(pt,"token: CTE\t lexemas: %s\n",lineaCTE);
	fclose(pt);
}

int listaBuscar(const t_lista* pl,t_info* dat,t_cmp comp)
{
    while(*pl){
		if(comp(dat,&(*pl)->dat)==0)
		{
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


///////FIN DE PRIMITVAS/////////////

%}
%union 
{ 
    int intValue; 
    float floatValue; 
    char *stringValue; 
} 

%token	PUT			
%token	AS			
%token	DIM			
%token	AND
%token	OR			
%token	GET			
%token	IF			
%token	ELSE			
%token	WHILE			
%token	LLAVE_I		
%token	LLAVE_F		
%token	OP_SUM		
%token	PAR_I			
%token	PAR_F		
%token	OP_AS			
%token	DIV			
%token	RES			
%token	MAYOR			
%token	MENOR			
%token	MAYOR_IGUAL	
%token	MENOR_IGUAL			
%token	INTEGER		
%token	FLOAT			
%token	STRING	
%token <stringValue>	ID
%token 	FIN_SENT		
%token 	SEPARADOR		
%token 	ESP			
%token 	CTE_ENT	
%token 	CTE_REAL	
%token 	CTE_HEX
%token 	CTE_OC
%token 	CTE_BIN
%token 	COMILLA		
%token 	TEXT_W
%token 	OP_MUL
%token 	COMENTARIO				
%token 	COMPARACION	
%token 	DISTINTO	
%token 	ASIG
%token 	MAX
%token 	IGUAL
%token	NOT
%start	programa

%%
programa :
	 programa sentencia {printf("	FIN programa\n");}
	|sentencia {printf("	FIN\n");};
	
sentencia:
	 expresion {printf("	Sentencia es expresion\n");}
	|bloque_declaracion {printf("	Sentencia es bloque_declaracion\n");}
	|asig {printf("	Sentencia es asig\n");}
	|iteracion {printf("	Sentencia es Iteracion\n");}
	|salida {printf("	Sentencia es salida\n");}
	//|maximo {printf("	Sentencia es maximo\n");}
	|decision {printf("	Sentencia es decision\n");}
	|entrada {printf("	Sentencia es entrada\n");}
	|COMENTARIO;

//bloque_declaracion:
	 //bloque_declaracion bloque_declaracion {printf("	Multiples bloque_declaracion\n");}|
	// bloque_declaracion {printf("	bloque_declaracion\n");};

bloque_declaracion:
	 DIM declaracionesvar AS declaraciontipo {printf("	Defincion bloque declaracion\n");};
	 
declaracionesvar:
	 MENOR lista_var MAYOR {printf("	Declaracion de variables\n");};
	 
lista_var: 
	 lista_var SEPARADOR ID {printf("	Conjunto de variables\n");}
	|ID {printf("	Una sola variable\n");};

declaraciontipo:
	 MENOR tipo_dato_lista MAYOR {printf("	Declaracion de tipo");};
	 
tipo_dato_lista:
	 tipo_dato_lista SEPARADOR tipo_dato  {printf("	Declaraciones de tipos");}
	|tipo_dato {printf("	Declaracion de tipo");};

tipo_dato:
	 INTEGER  {printf("	Tipo Integer\n");}
	|FLOAT  {printf("	Tipo Float\n");}
	|STRING  {printf("	Tipo String\n");};


asig:
	ID  ASIG expresion FIN_SENT{printf("	ID=Expresion es Asignacion: %s\n",yylval.stringValue);
	/*strcpy(dat.token,"ID");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastID += strlen(yylval.stringValue)+1;
	}
	*/
	
	};
	
expresion:
	termino {printf("	Termino es Expresion\n");}
	|expresion OP_SUM termino {printf("	Expresion+Termino es Expresion\n");}
	|expresion RES termino {printf("	Expresion-Termino es Expresion\n");};
	
termino:
	factor {printf("	Factor es Termino\n");}
	|termino  OP_MUL factor {printf("	Termino*Factor es Termino\n");}
	|termino  DIV factor {printf("	Termino/Factor es Termino\n");};
factor:
	ID {printf("	ID es Factor: %s\n",yylval.stringValue);
	strcpy(dat.token,"ID");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastID += strlen(yylval.stringValue)+1;
	}}
	|CTE_ENT {printf("	CTE Entera es Factor\n");}
	|CTE_REAL {printf("	CTE Real es Factor\n");}
	|CTE_HEX {printf("	CTE Hexa es Factor\n");}
	|CTE_OC {printf("	CTE Octal es Factor\n");}
	|CTE_BIN {printf("	CTE Binaria es Factor\n");}
	|maximo {printf("	maximo es es Factor\n");}
	|PAR_I expresion PAR_F {printf("	Expresion ente parentesis es Factor\n");};

salida:
	 PUT TEXT_W FIN_SENT {printf("	Sentencia de salida por texto\n");}
	|PUT ID FIN_SENT {printf("	Sentencia de salida de variable\n");};
	 
entrada:
	 GET ID	FIN_SENT {printf("	Sentencia de entrada\n");};
	 
iteracion:
	 WHILE PAR_I condicion PAR_F bloque {printf("	Definicion de iteracion con bloque\n");}
	|WHILE PAR_I condicion PAR_F sentencia {printf("	Definicion de iteracion con una sentencia\n");};

condicion:
	 comparacion AND comparacion {printf("	Comparacion True y Comparacion TRUE\n");}
	|comparacion OR comparacion {printf("	Comparacion True o Comparacion TRUE\n");} 
	|comparacion {printf("	Comparacion unica\n");} 
	|NOT comparacion {printf("	Comparacion negada\n");} ;

comparacion:
	 expresion comparador expresion {printf("	Expresion comparada contra expresion\n");}
	|expresion {printf("	Expresion unica en la comparacion\n");};

comparador:
	 IGUAL {printf("	Comparador igual\n");}
	|MAYOR {printf("	Comparador mayor\n");}
	|MENOR {printf("	Comparador menor\n");}
	|MAYOR_IGUAL {printf("	Comparador mayor igual\n");}
	|MENOR_IGUAL {printf("	Comparador menor igual\n");}
	|DISTINTO {printf("	Comparador disntinto\n");};
	
bloque:
	 LLAVE_I programa LLAVE_F {printf("	Bloque de codigo\n");};
	 
bloque_anidado:
	 LLAVE_I decision_IF LLAVE_F {printf("	Bloque de codigo\n");};

maximo:
	MAX PAR_I lista_factores PAR_F {printf("	Definicion del maximo\n");};

lista_factores:
	 lista_factores SEPARADOR expresion {printf("	Definicion de la lista de valroes\n");}
	|expresion {printf("	La lista puede ser un terminon\n");};

decision_IF:
	 IF PAR_I condicion PAR_F bloque {printf("	Definicion de IF con bloque\n");}	
	|IF PAR_I condicion PAR_F sentencia {printf("	Definicion de IF con bloque\n");}
	|IF PAR_I condicion PAR_F bloque_anidado {printf("	Definicion de IF con bloque\n");}
	;
decision_else:
	 ELSE bloque {printf("	Definicion de IF con bloque\n");}
	|ELSE sentencia {printf("	Definicion de IF con bloque\n");}
	|ELSE bloque_anidado {printf("	Definicion de IF con bloque\n");}
	;
decision:
	decision_IF decision_else {printf("	Definicion de IF con bloque\n");}
	|decision_IF sentencia {printf("	Definicion de IF con bloque\n");}
	;
/*
bloque_else:
	 ELSE bloque {printf("	Else con sentencias\n");}
	|ELSE sentencia {printf("	Else con una sola sentencia\n");}
	//|{printf("	Else vacio\n");}*/
	
%%	
/*
int yylex(void)
{
	return 0;
}*/
int main (int argc,char *argv[]){

 //creo la tabla de simbolos
 listaCrear(&lista1);
	
 if ((yyin=fopen(argv[1],"rt"))==NULL)
 {
  	printf("\nNo se puede abrir el archivo: %s\n",argv[1]);
 }
 else{
	yyparse();
 }
 fclose(yyin);
 //Genero la tabla de simbolos
 listaVaciar(&lista1,&dat);
 return 0;
}
int yyerror(void)
	{ 
 	  printf("Syntax Error\n");
	  system("Pause");
          exit (1);
	}

