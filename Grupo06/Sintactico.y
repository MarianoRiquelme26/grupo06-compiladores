%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "files_h/tercetos.h"
#include "files_h/constantes.h"
#include "files_h/ts.h"
#include "files_h/pila.h"
int yystopparser=0;
FILE *yyin;
int yyerror();
int yylex();
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
	pt=fopen("ts.txt","w");
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

//////////COMENZAMOS TERCETOS ///////////

	void insertarEnArrayDeclaracion(char *);
	void validarDeclaracionTipoDato(char *);
	char * negarComparador(char*);
	char * obtenerNuevoNombreEtiqueta(char *);
	void insertarEnArrayComparacionTipos(char *);
	void insertarEnArrayComparacionTiposDirecto(char *);
	void imprimirArrayComparacionTipos();
	void compararTipos();
	char * tipoConstanteConvertido(char*);
	void insertarEnArrayTercetos(char *operador, char *operando1, char *operando2);
	void crearTercetosDelArray();
	void guardarTipoDato(char *);

	// Pilas para resolver GCI
	t_pila pila;
	t_pila pila_condicion_doble;
	//t_pila pila_inlist;
	t_pila pilaDatos;
	t_pila pilaTemporal;
	//t_pila pilaDatosInversa;
	char condicion[5];

	// Para assembler
	FILE * pfASM; // Final.asm
	//t_pila pila;  // Pila saltos
	//t_pila pVariables;  // Pila variables

	void generarAssembler();
	void generarEncabezado();
	void generarDatos();
	void generarCodigo();
	void imprimirInstrucciones();
	void generarFin();

	// arrays
	char * arrayDeclaraciones[100];
	char * arrayTipoDato[100];
	int longitud_arrayDeclaraciones = 0;
	int longitud_arrayTipoDato = 0; // incrementos
	char * arrayComparacionTipos[100];	// array para comparar tipos
	int longitud_arrayComparacionTipos = 0; // incremento en el array arrayComparacionTipos
	char tipoDato[100];
	char ids[100];

	// Auxiliar para manejar tercetos;
	int indiceExpresion, indiceTermino, indiceFactor, indiceLongitud;
	int indiceAux, indiceUltimo, indiceIzq, indiceDer, indiceComparador, indiceComparador1, indiceComparador2,
	indiceId;
	int indicePrincipioBloque;
	char idAsignarStr[50];
	
	int startEtiqueta = 0;
	

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
	 programa sentencia {
		crear_pila(&pilaDatos);
		crear_pila(&pilaTemporal);
		printf("	FIN programa\n");}
	|sentencia { 
		crear_pila(&pilaDatos);
		crear_pila(&pilaTemporal);
		crearArchivoTS();
		crearArchivoTercetosIntermedia();
		printf("	FIN sentencia\n");};
	
sentencia:
	 expresion {printf("	Sentencia es expresion\n");}
	|bloque_declaracion {printf("	Sentencia es bloque_declaracion\n");}
	|asig {printf("	Sentencia es asignacion\n");}
	|iteracion {printf("	Sentencia es Iteracion\n");}
	|salida {crearArchivoTercetosIntermedia() ; printf("	Sentencia es salida\n");}
	|decision {printf("	Sentencia es decision\n");}
	|entrada {printf("	Sentencia es entrada\n");}
	|COMENTARIO;


bloque_declaracion: DIM declaraciones;
	
declaraciones:
declaracion | declaraciones declaracion;

declaracion:
	MENOR NODO
	{
			while((pila_vacia(&pilaDatos) != PILA_VACIA ) && (pila_vacia(&pilaTemporal) != PILA_VACIA))
			{
				sacar_de_pila(&pilaTemporal, &tipoDato);
				sacar_de_pila(&pilaDatos, &ids);
				insertarEnArrayDeclaracion(ids);
				if(strcmp(tipoDato, "STRING") == 0)
				{
					validarDeclaracionTipoDato("STRING");
				}
				else{
						if(strcmp(tipoDato, "FLOAT") == 0)
							{
							validarDeclaracionTipoDato("FLOAT");
							}

						else{
							validarDeclaracionTipoDato("INTEGER");
								}
				}
			}
  }
  MAYOR;

NODO:
ID MAYOR AS MENOR TIPO_DATO
{
	poner_en_pila(&pilaDatos, yylval.stringValue);
};
NODO:
	ID SEPARADOR NODO SEPARADOR TIPO_DATO
	{
		poner_en_pila(&pilaDatos, yylval.stringValue);
	};

TIPO_DATO:

	STRING {
	poner_en_pila(&pilaTemporal, "STRING");
	}
	|
	INTEGER {
	 poner_en_pila(&pilaTemporal, "INTEGER");

	}
	| FLOAT{
		poner_en_pila(&pilaTemporal, "FLOAT");

	};


asig:
	lista_id expresion
	{
		printf("\t\tASIGNACION\n");
		//compararTipos();
		indiceAux = crearTerceto(idAsignarStr,"_","_");
		crearTerceto("=",armarIndiceI(indiceAux),armarIndiceD(indiceExpresion));
	};

lista_id:
	ID ASIG
	{
		//insertarEnArrayComparacionTipos(yylval.stringValue);
		strcpy(idAsignarStr, yylval.stringValue);
	};
	
expresion:
	termino {indiceExpresion = indiceTermino; 
	 printf("	Termino es Expresion\n");}
	|expresion OP_SUM termino {indiceExpresion = crearTerceto("+",armarIndiceI(indiceExpresion),armarIndiceD(indiceTermino));
	 printf("	Expresion + Termino es Expresion\n");}
	|expresion RES termino {indiceExpresion = crearTerceto("-",armarIndiceI(indiceExpresion),armarIndiceD(indiceTermino));
	 printf("	Expresion - Termino es Expresion\n");};
	
termino:
	factor {indiceTermino = indiceFactor; 
	 printf("	Factor es Termino\n");}
	|termino  OP_MUL factor {indiceTermino = crearTerceto("*",armarIndiceI(indiceTermino),armarIndiceD(indiceFactor)); 
	 printf("	Termino * Factor es Termino\n");}
	|termino  DIV factor {indiceTermino = crearTerceto("/",armarIndiceI(indiceTermino),armarIndiceD(indiceFactor));
	 printf("	Termino / Factor es Termino\n");};

factor:
	ID {indiceFactor = crearTerceto(yylval.stringValue,"_","_"); 
	 printf("	ID es Factor: %s\n",yylval.stringValue);
	//insertarEnArrayComparacionTipos(yylval.stringValue);
	strcpy(dat.token,"ID");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastID += strlen(yylval.stringValue)+1;
	}}
	|CTE_ENT {indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
	 printf("	CTE Entera es Factor: %s\n",yylval.stringValue);
	 insertarEnArrayComparacionTipos(yylval.stringValue);
	strcpy(dat.token,"CTE");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastCT += strlen(yylval.stringValue)+1;
	}}
	|CTE_REAL {indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
	 printf("	CTE Real es Factor: %s\n",yylval.stringValue);
	 insertarEnArrayComparacionTipos(yylval.stringValue);
	strcpy(dat.token,"CTE");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastCT += strlen(yylval.stringValue)+1;
	}}
	|CTE_HEX {indiceFactor = crearTerceto(yylval.stringValue,"_","_");
	 printf("	CTE Hexadecimal es Factor: %s\n",yylval.stringValue);
	strcpy(dat.token,"CTE");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastCT += strlen(yylval.stringValue)+1;
	}}
	|CTE_OC {indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
	 printf("	CTE Octal es Factor: %s\n",yylval.stringValue);
	strcpy(dat.token,"CTE");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastCT += strlen(yylval.stringValue)+1;
	}}
	|CTE_BIN {indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
	 printf("	CTE Binaria es Factor: %s\n",yylval.stringValue);
	strcpy(dat.token,"CTE");
	strcpy(dat.lexema,yylval.stringValue);
	if(!listaBuscar(&lista1,&dat,comp)){
		insertarLista(&lista1,&dat);
		contadorLetrastCT += strlen(yylval.stringValue)+1;
	}}
	|maximo {printf("	Maximo es Factor\n");}
	|PAR_I expresion PAR_F {printf("	Expresion entre parentesis es Factor\n");};

salida:
	 PUT TEXT_W FIN_SENT {printf("	Definicion de Salida\n");
	 indiceAux = crearTerceto(yylval.stringValue,"_","_");
	 crearTerceto("PUT",armarIndiceI(indiceAux),"_");}
	|PUT ID FIN_SENT {printf("	Definicion de Salida\n");
	 indiceAux = crearTerceto(yylval.stringValue,"_","_");
	 crearTerceto("PUT",armarIndiceI(indiceAux),"_");};
	 
entrada:
	 GET ID	{indiceAux = crearTerceto(yylval.stringValue,"_","_");
	 crearTerceto("GET",armarIndiceI(indiceAux),"_");}
	 FIN_SENT {printf("	Sentencia de entrada\n");};
	 
iteracion:
	 WHILE PAR_I condicion PAR_F bloque {	printf("\t\tDefinicion de iteracion\n");
	int indiceDesapilado;
	int indiceActual = obtenerIndiceActual();
	if(pila_vacia(&pila_condicion_doble) == PILA_VACIA)
	{
		sacar_de_pila(&pila, &indiceDesapilado);
		modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
	}
	else
	{
		if(strcmp(condicion,"AND") == 0)
		{
			sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
			sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
		}
		if(strcmp(condicion,"OR") == 0)
		{
			sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
			sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indicePrincipioBloque));
		}
		// Debo desapilar el ultimo porque no me sirve
		sacar_de_pila(&pila, &indiceDesapilado);
	}
	sacar_de_pila(&pila, &indiceDesapilado);
	crearTerceto("JMP",armarIndiceI(indiceDesapilado),"_");
	};

condicion:
	 comparacion {indiceComparador1 = indiceComparador;} AND comparacion {printf("	Comparacion con AND\n");
	 				printf("\t\tCONDICION DOBLE AND\n");
					indiceComparador2 = indiceComparador;
					strcpy(condicion, "AND");
					poner_en_pila(&pila_condicion_doble,&indiceComparador1);
					poner_en_pila(&pila_condicion_doble,&indiceComparador2);}
	|comparacion {
						indiceComparador1 = indiceComparador;
						char *operador = obtenerTerceto(indiceComparador1,1);
						char *operadorNegado = negarComparador(operador);
						modificarTerceto(indiceComparador1,1,operadorNegado);
						startEtiqueta = 0;
					} OR comparacion {printf("	Comparacion con OR\n");
						indiceComparador2 = indiceComparador;
						strcpy(condicion, "OR");
						poner_en_pila(&pila_condicion_doble,&indiceComparador1);
						poner_en_pila(&pila_condicion_doble,&indiceComparador2);
						} 
	|comparacion {printf("	Comparacion simple\n");} 
	|NOT comparacion {printf("	Comparacion negada\n");
						char *operador = obtenerTerceto(indiceComparador,1);
						char *operadorNegado = negarComparador(operador);
						modificarTerceto(indiceComparador,1,operadorNegado);} ;

comparacion:
	 expresion { indiceIzq = indiceExpresion; } comparador expresion {printf("	Expresion comparada contra expresion\n");
				compararTipos();
				indiceDer = indiceExpresion;
				crearTerceto("CMP",armarIndiceI(indiceIzq),armarIndiceD(indiceDer));
				char comparadorDesapilado[8];
				sacar_de_pila(&pila, &comparadorDesapilado);
				indiceComparador = crearTerceto(comparadorDesapilado,"_","_");
				poner_en_pila(&pila,&indiceComparador);
				}
	|expresion {printf("	Expresion unica en la comparacion\n");};

comparador:
	 IGUAL {printf("	Comparador igual\n");
		char comparadorApilado[8] = "JE";
		poner_en_pila(&pila,&comparadorApilado);}
	|MAYOR {printf("	Comparador mayor\n"); 
		char comparadorApilado[8] = "JA";
		poner_en_pila(&pila,&comparadorApilado);}
	|MENOR {printf("	Comparador menor\n");
		char comparadorApilado[8] = "JB";
		poner_en_pila(&pila,&comparadorApilado);}
	|MAYOR_IGUAL {printf("	Comparador mayor igual\n");
		char comparadorApilado[8] = "JAE";
		poner_en_pila(&pila,&comparadorApilado);}
	|MENOR_IGUAL {printf("	Comparador menor igual\n");
		char comparadorApilado[8] = "JBE";
		poner_en_pila(&pila,&comparadorApilado);}
	|DISTINTO {printf("	Comparador distinto\n");
		char comparadorApilado[8] = "JNE";
		poner_en_pila(&pila,&comparadorApilado);};
	
bloque:
	 LLAVE_I programa LLAVE_F {printf("	Bloque de codigo\n");};
	 
maximo:
	MAX PAR_I lista_factores PAR_F {printf("	Definicion del maximo\n");};

lista_factores:
	 lista_factores SEPARADOR expresion {printf("	Definicion de la lista de valores\n");}
	|expresion;

decision:
	IF PAR_I condicion PAR_F
	bloque
	{
		int indiceDesapilado;
		int indiceActual = obtenerIndiceActual();
		if(pila_vacia(&pila_condicion_doble) == PILA_VACIA)
		{
			sacar_de_pila(&pila, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual));
		}
		else
		{
			if(strcmp(condicion,"AND") == 0)
			{
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual));
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual));
			}
			if(strcmp(condicion,"OR") == 0)
			{
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual));
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceComparador+1));
			}
		}
	}
	|
	IF PAR_I condicion PAR_F bloque {printf("\t\tIF\n");}
	ELSE
	{
		printf("\t\tELSE\n");
		int indiceDesapilado;
		int indiceActual = obtenerIndiceActual();
		if(pila_vacia(&pila_condicion_doble) == PILA_VACIA)
		{
			sacar_de_pila(&pila, &indiceDesapilado);
			modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
		}
		else
		{
			if(strcmp(condicion,"AND") == 0)
			{
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
			}
			if(strcmp(condicion,"OR") == 0)
			{
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual+1));
				sacar_de_pila(&pila_condicion_doble, &indiceDesapilado);
				modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceComparador+1));
			}
		}
		indiceAux = crearTerceto("JMP","_","_");
		poner_en_pila(&pila, &indiceAux);

		startEtiqueta = 0;
	}
	bloque
	{
		int indiceDesapilado;
		int indiceActual = obtenerIndiceActual();
		sacar_de_pila(&pila, &indiceDesapilado);
		modificarTerceto(indiceDesapilado, 2, armarIndiceI(indiceActual));
	};
	
%%	

int main (int argc,char *argv[]){

 //Creo la tabla de simbolos
 listaCrear(&lista1);
	
 if ((yyin=fopen(argv[1],"rt"))==NULL)
 {
  	printf("\nNo se puede abrir el archivo: %s\n",argv[1]);
 }
 else{
	yyparse();
 }
 fclose(yyin);
 //Cargo la tabla de simbolos
 listaVaciar(&lista1,&dat);
 return 0;
}
int yyerror(void){ 
 	  printf("Syntax Error\n");
	  system("Pause");
      exit (1);
}

char * negarComparador(char* comparador)
{
	if(strcmp(comparador,"JA") == 0)
		return "JBE";
	if(strcmp(comparador,"JB") == 0)
		return "JAE";
	if(strcmp(comparador,"JNB") == 0)
		return "JB";
	if(strcmp(comparador,"JBE") == 0)
		return "JA";
	if(strcmp(comparador,"JE") == 0)
		return "JNE";
	if(strcmp(comparador,"JNE") == 0)
		return "JE";
	return NULL;
}

void compararTipos()
{
	// imprimirArrayComparacionTipos();
	char* tipoBase = arrayComparacionTipos[0];
	int i;
	for (i=1; i < longitud_arrayComparacionTipos; i++)
	{
		char* tipoAComparar = arrayComparacionTipos[i];
		if(strcmp(tipoBase, tipoAComparar) != 0)
		{
			char msg[300];
		    sprintf(msg, "ERROR en etapa GCI - Tipo de datos incompatibles. Tipo 1: \'%s\' Tipo 2: \'%s\'", tipoBase, tipoAComparar);
		
		}
	}
	longitud_arrayComparacionTipos = 0;
}

void insertarEnArrayDeclaracion(char * val)
{
    char * aux = (char *) malloc(sizeof(char) * (strlen(val) + 1));
    strcpy(aux, val);
    arrayDeclaraciones[longitud_arrayDeclaraciones] = aux;
    longitud_arrayDeclaraciones++;
}

void insertarEnArrayComparacionTipos(char * val)
{
	if(existeTokenEnTS(yylval.stringValue) == NO_EXISTE)
	{
		char msg[300];
		sprintf(msg, "ERROR en etapa GCI - Variable \'%s\' no declarada en la seccion declaracion", yylval.stringValue);
	
	}
	// Inserto tipo en array
	char * tipo = recuperarTipoTS(val);
	tipo = tipoConstanteConvertido(tipo);
	char * aux = (char *) malloc(sizeof(strlen(tipo) + 1));
	strcpy(aux, tipo);
	arrayComparacionTipos[longitud_arrayComparacionTipos] = aux;
	longitud_arrayComparacionTipos++;
}

void validarDeclaracionTipoDato(char * tipo)
{
	int i;
	for (i=0; i < longitud_arrayDeclaraciones; i++)
	{
		if(existeTokenEnTS(arrayDeclaraciones[i]) == NO_EXISTE)
		{
			insertarTokenEnTS(tipo,arrayDeclaraciones[i]);
		}
		else
		{
			char msg[300];
			sprintf(msg, "ERROR en etapa GCI - Variable \'%s\' ya declarada", arrayDeclaraciones[i]);
			
		}
	}
	longitud_arrayDeclaraciones = 0;
}
char * tipoConstanteConvertido(char* tipoVar)
{
	if(strcmp(tipoVar, "INTEGER") != 0 && strcmp(tipoVar, "FLOAT") != 0 && strcmp(tipoVar, "STRING") != 0)
	{
		if(strcmp(tipoVar, "CTE_ENT") == 0)
		{
			return "INTEGER";
		}
		else
			if(strcmp(tipoVar, "CTE_REAL") == 0)
			{
				return "FLOAT";
			}
			else
				if(strcmp(tipoVar, "CONST_STR") == 0)
				{
					return "STRING";
				}
				else
				{
					return NULL;
				}
	}
	return tipoVar;
}