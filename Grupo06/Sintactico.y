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

//////////COMENZAMOS///////////

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
	t_pila pilaDatos;
	t_pila pilaTemporal;
	char condicion[5];

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
	
	// Para assembler
	FILE * pfASM; // Final.asm
	t_pila pila;  // Pila saltos
	t_pila pVariables;  // Pila variables

	void generarAssembler();
	void generarEncabezado();
	void generarDatos();
	void generarCodigo();
	void imprimirInstrucciones();
	void generarFin();
	
	int startEtiqueta = 0;

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
%token 	<stringValue> CTE_STR
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
		prepararTSParaAssembler();
		crearArchivoTS();
		crearArchivoTercetosIntermedia();
		generarAssembler();
		printf("	FIN sentencia\n");};
	
sentencia:
	 expresion {printf("	Sentencia es expresion\n");}
	|bloque_declaracion {printf("	Sentencia es bloque_declaracion\n");}
	|asig {printf("	Sentencia es asignacion\n");}
	|iteracion 	{
		crearTerceto(obtenerNuevoNombreEtiqueta("fin_repeat"),"_","_");
		startEtiqueta = 0;
	}
	|salida {printf("	Sentencia es salida\n");}
	|decision {
		crearTerceto(obtenerNuevoNombreEtiqueta("fin_seleccion"),"_","_");
		startEtiqueta = 0;
	}
	|entrada {printf("	Sentencia es entrada\n");}
	|COMENTARIO;

bloque_declaracion:
	 DIM MENOR listaVariables MAYOR AS MENOR listaTipos MAYOR {printf("	Bloque declaracion\n");
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
	}};
	 
listaVariables:
	 listaVariables SEPARADOR ID{ poner_en_pila(&pilaDatos, yylval.stringValue);}
     |ID { poner_en_pila(&pilaDatos, yylval.stringValue);}
	 {printf("	Declaraciones variables\n");};
	 
listaTipos: 
	 listaTipos SEPARADOR tipo_dato
	|tipo_dato
	{printf("	Declaraciones tipos\n");};

tipo_dato:

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
	lista_id expresion FIN_SENT
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
	ID { if(startEtiqueta == 0)
		{
			crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
			startEtiqueta = 1;
		}
			indiceFactor = crearTerceto(yylval.stringValue,"_","_"); 
			printf("	ID es Factor: %s\n",yylval.stringValue);
			//insertarEnArrayComparacionTipos(yylval.stringValue);
	}
	|CTE_ENT { if(startEtiqueta == 0)
				{
				 crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
				 startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
				printf("	CTE Entera es Factor: %s\n",yylval.stringValue);
				insertarEnArrayComparacionTipos(yylval.stringValue);
	}
	|CTE_REAL { if(startEtiqueta == 0)
				{
					crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
					startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
				printf("	CTE Real es Factor: %s\n",yylval.stringValue);
				insertarEnArrayComparacionTipos(yylval.stringValue);
	}
	|CTE_STR {	if(startEtiqueta == 0)
				{
					crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
					startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
				printf("	CTE String es Factor: %s\n",yylval.stringValue);
				insertarEnArrayComparacionTipos(yylval.stringValue);}
	|CTE_HEX {	if(startEtiqueta == 0)
				{
					crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
					startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_");
				//insertarEnArrayComparacionTipos(yylval.stringValue);
				printf("	CTE Hexadecimal es Factor: %s\n",yylval.stringValue);
	 }
	|CTE_OC {	if(startEtiqueta == 0)
				{
					crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
					startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
				//insertarEnArrayComparacionTipos(yylval.stringValue);
				printf("	CTE Octal es Factor: %s\n",yylval.stringValue);
	}
	|CTE_BIN {	if(startEtiqueta == 0)
				{
					crearTerceto(obtenerNuevoNombreEtiqueta("inicio"),"_","_");
					startEtiqueta = 1;
				}
				indiceFactor = crearTerceto(yylval.stringValue,"_","_") ;
				//insertarEnArrayComparacionTipos(yylval.stringValue);
				printf("	CTE Binaria es Factor: %s\n",yylval.stringValue);
	}
	|maximo {printf("	Maximo es Factor\n");}
	|PAR_I expresion PAR_F {printf("	Expresion entre parentesis es Factor\n");};

salida:
	 PUT CTE_STR FIN_SENT {
	 indiceAux = crearTerceto(yylval.stringValue,"_","_");
	 crearTerceto("PUT",armarIndiceI(indiceAux),"_");
	 printf("	Definicion de Salida\n");}
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
					poner_en_pila(&pila_condicion_doble,&indiceComparador2);
					startEtiqueta = 0;}
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
						startEtiqueta = 0;} 
	|comparacion {printf("	Comparacion simple\n");
				  startEtiqueta = 0;} 
	|NOT comparacion {printf("	Comparacion negada\n");
						char *operador = obtenerTerceto(indiceComparador,1);
						char *operadorNegado = negarComparador(operador);
						modificarTerceto(indiceComparador,1,operadorNegado);
						startEtiqueta = 0;};

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

 if ((yyin=fopen(argv[1],"rt"))==NULL)
 {
  	printf("\nNo se puede abrir el archivo: %s\n",argv[1]);
 }
 else{
	yyparse();
 }
 fclose(yyin);

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
				if(strcmp(tipoVar, "CTE_STR") == 0)
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

char * obtenerNuevoNombreEtiqueta(char * val)
{
	static char nombreEtiqueta[50];
	int indiceActualTerceto = obtenerIndiceActual();
	sprintf(nombreEtiqueta, "ETIQ_%s_%d", val, indiceActualTerceto);
	return nombreEtiqueta;
}

//////// ASSEMBLER 
//Funcion que se encarga de generar el archivo y completarlo
void generarAssembler(){
	pfASM = fopen("Final.asm", "w");
    // Creo pilas para tercetos.
    crear_pila(&pVariables);
    generarEncabezado();
    generarDatos();
    generarCodigo();
    generarFin();
    fclose(pfASM);
}

void generarEncabezado(){
    fprintf(pfASM, "\nINCLUDE macros2.asm\t\t ;incluye macros\n");
    fprintf(pfASM, "INCLUDE number.asm\t\t ;incluye el asm para impresion de numeros\n");
    fprintf(pfASM, "\n.MODEL LARGE\t\t ; tipo del modelo de memoria usado.\n");
    fprintf(pfASM, ".386\n");
	fprintf(pfASM, ".387\n");
    fprintf(pfASM, ".STACK 200h\t\t ; bytes en el stack\n");
}

void generarDatos(){
    fprintf(pfASM, "\t\n.DATA\t\t ; comienzo de la zona de datos.\n");
    fprintf(pfASM, "\tTRUE equ 1\n");
    fprintf(pfASM, "\tFALSE equ 0\n");
    fprintf(pfASM, "\tMAXTEXTSIZE equ %d\n",COTA_STR);

	int i;
	int tamTS = obtenerTamTS();
	for(i=0; i<tamTS; i++)
	{
		if(strcmp(tablaSimbolos[i].tipo, "INTEGER") == 0 )
		{
			fprintf(pfASM, "\t%s dd 0\n",tablaSimbolos[i].nombre);
		}
		if(strcmp(tablaSimbolos[i].tipo, "FLOAT") == 0 )
		{
			fprintf(pfASM, "\t%s dd 0.0\n",tablaSimbolos[i].nombre);
		}
		if(strcmp(tablaSimbolos[i].tipo, "STRING") == 0 )
		{
			fprintf(pfASM, "\t%s db MAXTEXTSIZE dup(?), '$'\n",tablaSimbolos[i].nombre);
		}
		if(strcmp(tablaSimbolos[i].tipo, "CTE_ENT") == 0 || strcmp(tablaSimbolos[i].tipo, "CTE_REAL") == 0 )
		{
            fprintf(pfASM, "\t%s dd %s\n",tablaSimbolos[i].nombre, tablaSimbolos[i].valor);
		}
		if(strcmp(tablaSimbolos[i].tipo, "CTE_STR") == 0)
		{
			int longitud = strlen(tablaSimbolos[i].valor);
			int size = COTA_STR - longitud;
			fprintf(pfASM, "\t%s db %s, '$', %d dup(?)\n", tablaSimbolos[i].nombre, tablaSimbolos[i].valor, size);
		}
	}
	// Auxiliares
	int tamTercetos = obtenerIndiceActual();
	for(i=0; i<tamTercetos; i++)
	{
		if(strstr(tercetos[i].operador, "ETIQ") == NULL)
		{
			fprintf(pfASM, "\t@aux%d dd 0.0\n",i);
		}
	}
}

void imprimirFuncString(){
    int c;
    FILE *file;
    file = fopen("string.asm", "r");
    if (file) {
        fprintf(pfASM,"\n");
        while ((c = getc(file)) != EOF)
        fprintf(pfASM,"%c",c);
        fprintf(pfASM,"\n\n");
        fclose(file);
    }
}

void generarCodigo(){
    fprintf(pfASM, "\n.CODE ;Comienza sector de codigo\n");

    imprimirFuncString();

    //Comienza codigo usuario
    fprintf(pfASM, "START: \t\t;Codigo assembler resultante.\n");
    fprintf(pfASM, "\tmov AX,@DATA \t\t;Comienza sector de datos\n");
    fprintf(pfASM, "\tmov DS,AX\n");
    fprintf(pfASM, "\tfinit\n\n");

	int i;
	int tamTercetos = obtenerIndiceActual();

	char aux1[50];
	char aux2[50];
	char auxEtiqueta[50];

	int flag;
	for(i=0; i<tamTercetos; i++)
	{
		char operador[50];
		strcpy(operador,tercetos[i].operador);
		flag = 0;

		if(strcmp(operador, ":=") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;ASIGNACIÓN\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			char * tipo = recuperarTipoTS(aux1);
    		char auxTipo[50] = "";
			strcpy(auxTipo, tipo);

			if(strcmp(tipo,"CTE_STR") == 0 || strcmp(tipo,"STRING") == 0)
			{
				fprintf(pfASM, "\tmov ax,@DATA\n");
                fprintf(pfASM, "\tmov es,ax\n");
                fprintf(pfASM, "\tmov si,OFFSET %s ;apunta el origen al auxiliar\n",aux1);
                fprintf(pfASM, "\tmov di,OFFSET %s ;apunta el destino a la cadena\n",aux2);
				fprintf(pfASM, "\tcall COPIAR ;copia los string\n\n");
			}
			else
			{
				fprintf(pfASM, "\tfld %s\n",aux1);
                fprintf(pfASM, "\tfstp %s\n\n",aux2);
			}
		}

		if(strcmp(operador, "CMP") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;CMP\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			// fprintf(pfASM,"\t%s\n",auxEtiqueta);
			fprintf(pfASM, "\tfld %s\n",aux1);
            fprintf(pfASM, "\tfld %s\n",aux2);
            fprintf(pfASM, "\tfcomp\n");
            fprintf(pfASM, "\tfstsw ax\n");
            fprintf(pfASM, "\tfwait\n");
            fprintf(pfASM, "\tsahf\n\n");
		}

		if(strstr(operador, "ETIQ") != NULL)
		{
			flag = 1;
			fprintf(pfASM,"\n\n%s:\n",operador);
		}

		if(strcmp(operador, "JMP") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tjmp %s\n",etiqueta);
		}

		if(strcmp(operador, "JE") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tje %s\n",etiqueta);
		}

		if(strcmp(operador, "JNE") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tjne %s\n", etiqueta);
		}

		if(strcmp(operador, "JB") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tjb %s\n", etiqueta);
		}

		if(strcmp(operador, "JBE") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tjbe %s\n", etiqueta);
		}

		if(strcmp(operador, "JA") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tja %s\n", etiqueta);
		}

		if(strcmp(operador, "JAE") == 0)
		{
			flag = 1;
			int indiceIzquierdo = desarmarIndice(tercetos[i].operandoIzq);
			char* etiqueta = obtenerTerceto(indiceIzquierdo, 1);
            fprintf(pfASM, "\tjae %s\n", etiqueta);
		}

		if(strcmp(operador, "-") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;RESTA\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

            fprintf(pfASM, "\tfld %s\n",aux1);
            fprintf(pfASM, "\tfld %s\n",aux2);
            fprintf(pfASM, "\tfsub\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}

		if(strcmp(operador, "+") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;SUMA\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			// fprintf(pfASM,"\t%s\n",auxEtiqueta);
			fprintf(pfASM, "\tfld %s\n",aux1);
            fprintf(pfASM, "\tfld %s\n",aux2);
            fprintf(pfASM, "\tfadd\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}

		if(strcmp(operador, "*") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;MULTIPLICACION\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			fprintf(pfASM, "\tfld %s\n",aux1);
            fprintf(pfASM, "\tfld %s\n",aux2);
            fprintf(pfASM, "\tfmul\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}

		if(strcmp(operador, "/") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;DIVISION\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			fprintf(pfASM, "\tfld %s\n",aux1);
            fprintf(pfASM, "\tfld %s\n",aux2);
            fprintf(pfASM, "\tfdiv\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}

		if(strcmp(operador, "MOD") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;MOD\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);
			
			fprintf(pfASM, "\tfld %s\n",aux1);
			fprintf(pfASM, "\tfld %s\n",aux2);
			fprintf(pfASM, "\tfdiv\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}


		if(strcmp(operador, "DIV") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;DIV\n");
			sacar_de_pila(&pVariables,&aux2);
			sacar_de_pila(&pVariables,&aux1);

			fprintf(pfASM, "\tfild %s\n",aux1);
			fprintf(pfASM, "\tfild %s\n",aux2);
			fprintf(pfASM, "\tfdiv\n");

			char auxStr[50] = "";
			sprintf(auxStr, "@aux%d",i);
			fprintf(pfASM, "\tfstp %s\n\n",auxStr);
			insertarTokenEnTS("",auxStr);
			poner_en_pila(&pVariables,&auxStr);
		}

		if(strcmp(operador, "GET") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;GET\n");
			sacar_de_pila(&pVariables,&aux1);

			char * tipo = recuperarTipoTS(aux1);
    		char auxTipo[50] = "";
			strcpy(auxTipo, tipo);

			if(strcmp(tipo,"CTE_STR") == 0 || strcmp(tipo,"STRING") == 0)
			{
				fprintf(pfASM,"\tdisplayString %s\n",aux1);
                fprintf(pfASM, "\tnewLine 1\n\n");
			}
			if(strcmp(tipo,"CONST_INT") == 0 || strcmp(tipo,"INTEGER") == 0)
			{
   				fprintf(pfASM,"\tDisplayInteger %s 2\n",aux1);
                fprintf(pfASM, "\tnewLine 1\n\n");
			}
			if(strcmp(tipo,"CONST_REAL") == 0 || strcmp(tipo,"REAL") == 0)
			{
				fprintf(pfASM,"\tDisplayFloat %s 2\n",aux1);
                fprintf(pfASM, "\tnewLine 1\n\n");
			}
		}

		if(strcmp(operador, "PUT") == 0)
		{
			flag = 1;
			fprintf(pfASM,"\t;PUT\n");
			sacar_de_pila(&pVariables,&aux1);

			char * tipo = recuperarTipoTS(aux1);
    		char auxTipo[50] = "";
			strcpy(auxTipo, tipo);

			if(strcmp(tipo,"CTE_STR") == 0 || strcmp(tipo,"STRING") == 0)
			{
				fprintf(pfASM,"\tgetString %s\n\n",aux1);
			}
			else
			{
				fprintf(pfASM,"\tGetFloat %s\n\n",aux1);
			}
		}

		if(flag == 0)
		{
			char * nombre = recuperarNombreTS(operador);
			char auxNombre[50] = "";
			strcpy(auxNombre, nombre);
			poner_en_pila(&pVariables,&auxNombre);
		}
	}

	while(pila_vacia(&pVariables) != PILA_VACIA)
	{
		char varApilada[50] = "";
		sacar_de_pila(&pVariables, &varApilada);
	}
}

void generarFin(){
    fprintf(pfASM, "\nTERMINAR: ;Fin de ejecución.\n");
    fprintf(pfASM, "\tmov ax, 4C00h ;termina la ejecución.\n");
    fprintf(pfASM, "\tint 21h ;syscall\n");
    fprintf(pfASM, "\nEND START ;final del archivo.");
}