%{
#include "funciones.c"
#include "y.tab.h"

FILE  *yyin;

%}

%union {
      int int_val;
      float real_val;
      char* str_val;
}

//OPERADORES ARITMERICOS
%token OP_SUM
%token OP_RES
%token OP_MUL
%token OP_DIV 

//TIPOS DE DATOS
%token <int_val> INTEGER
%token <real_val> FLOAT
%token <str_val> STRING
%token <str_val> ID

//CARACTERES
%token COMA
%token FIN_SENT
%token OP_AS

//OPERADORES LOGICOS
%token MAYOR
%token MENOR
%token COMPARACION
%token MAYOR_IGUAL
%token MENOR_IGUAL
%token DISTINTO
%token OP_AND
%token OP_OR
%token OP_NOT

//PALABRAS RESERVADAS
%token WHILE
%token IF
%token GET
%token PUT
%token DIM
%token AS
%token PUT
%token MAXIMO

//PARENTESIS Y LLAVES Y CORCHETES
%token PAR_I
%token PAR_F
%token LLAVE_I
%token LLAVE_F
%token CORCHETE_I
%token CORCHETE_F

//TIPO VARIABLES
%token <str_val> INTEGER FLOAT STRING

%%


programa: 
      bloque_declaracion bloque 
      {
            printf("COMPILACION CORRECTA\n");
      }
      |bloque
      {
            printf("COMPILACION CORRECTA\n");
      }
      ;

bloque_declaracion:
      DIM declaracionesvar AS declaracionestipo
      {
            printf("DECLARACIONES OK\n");
      }
      ;
declaracionestipo:
      declaracionestipo declaraciontipo
      |declaraciontipo
      ;

declaraciontipo:
	  MENOR tipo_variable_lista MAYOR
	  |MENOR tipo_variable MAYOR
      {
        guardar_variables_ts();
      }
      ;
tipo_dato_lista:
		tipo_dato_lista COMA tipo_dato
		| tipo_dato


tipo_dato:
      INTEGER
      {
        strcpy(tipo_dato,$<str_val>1);
      }
      |FLOAT
      {
        strcpy(tipo_dato,$<str_val>1);
      }
      |STRING
      {
        strcpy(tipo_dato,$<str_val>1);
      }
      ;
	  
declaracionesvar:
      declaracionesvar declaracionvar
      |declaracionvar
      ;

declaracionvar:
	  MENOR tipo_variable_lista MAYOR
	  |MENOR tipo_variable MAYOR
      {
        guardar_variables_ts();
      }
      ;	  

lista_var:
      lista_var COMA ID
      {
        if(crear_lista_variable($<str_val>3)==NOT_SUCCESS){
            printf("NO HAY MAS MEMORIA \n");
            yyerror();
        }
      }
      |ID
      {
        crear_lista_variable($<str_val>1);
      }
      ;

bloque: 
      bloque sentencia
      |sentencia
      ;

sentencia: 
      asignacion
      |decision
            {
            printf("DECISION\n");
      }
      |iteracion
            {
            printf("ITERACION\n");
      }
      |maximo
      {
            printf("MAXIMO\n");
      }
      |salida
      |entrada
      ;

salida:
		PUT CADENA
		  {
			//guardar_cte_string($<str_val>2);
			printf("DISPLAY %s\n",$<str_val>2);
		  }
		  ;

entrada:
      GET ID
      {
            if(!existe_simbolo($<str_val>2)){
                  printf("NO SE DECLARO LA VARIABLE - %s - EN LA SECCION DE DEFINICIONES\n",$<str_val>2);
                  yyerror();
            }
            printf("GET %s\n",$<str_val>2 );
      }
      ;

maximo:
      MAXIMO PAR_I lista_factores PAR_C
      ;

lista_factores:
				lista_factores COMA expresion
				| termino
				|factor

asignacion: 
      ID OP_AS expresion
      {
            switch(verificar_asignacion($<str_val>1)){
                  case 1:     printf("NO SE DECLARO LA VARIABLE - %s - EN LA SECCION DE DEFINICIONES\n",$<str_val>1);
                              yyerror();
                              break;
                  case 2:     printf("ASIGNACION EXITOSA!\n");
                              break;
                  case 3:     printf("ERROR DE SINTAXIS, ASIGNACION ERRONEA, TIPOS DE DATOS INCORRECTOS.\n"); 
                              printf("USTED ESTA INTENTANDO ASIGNAR UNA CONSTANTE %s A UNA VARIABLE %s \n", ultima_expresion, simbolo_busqueda.tipo_dato);
                              yyerror();
                              break;
            }

      }
      |ID operador OP_AS expresion
      {
            printf("ASIGNACION ESPECIAL EXITOSA!\n");
      }
      |ID OP_AS CADENA
      {
            guardar_cte_string($<str_val>3);
            ultima_expresion = "string";
            switch(verificar_asignacion($<str_val>1)){
                  case 1:   printf("NO SE DECLARO LA VARIABLE - %s - EN LA SECCION DE DEFINICIONES\n",$<str_val>1);
                              yyerror();
                              break;
                  case 2:   printf("CONSTANTE STRING: %s\n",$<str_val>3);
                              printf("ASIGNACION EXITOSA!\n");
                              break;
                  case 3:   printf("ERROR DE SINTAXIS, ASIGNACION ERRONEA, TIPOS DE DATOS INCORRECTOS.\n"); 
                              printf("USTED ESTA INTENTANDO ASIGNAR UNA CONSTANTE %s A UNA VARIABLE %s \n", ultima_expresion, simbolo_busqueda.tipo_dato);
                              yyerror();
                              break;
            }
      }
      ;

operador:
      OP_SUMA
      |OP_RES
      |OP_MUL
      |OP_DIV
      ;

iteracion:
      WHILE P_A condicion P_C L_A bloque L_C 
      ;

decision:
      IF P_A condicion P_C L_A bloque L_C 
      ;

condicion: 
      comparacion OP_L_O comparacion
      |comparacion OP_L_A comparacion
      |comparacion
      |OP_L_N comparacion
      ;

comparacion: 
      expresion comparador expresion
      |expresion
      ;

comparador:
     MAYOR
	|MENOR
	|COMPARACION
	|MAYOR_IGUAL
	|MENOR_IGUAL
	|DISTINTO
	|OP_AND
	|OP_OR
	|OP_NOT
    ;

		
expresion:
      termino
      |expresion OP_RES termino
      {
            printf("RESTA\n");
      }
      |expresion OP_SUMA termino
      {
            printf("SUMA\n");
      }
      ;

termino: 
      factor
      |termino OP_MUL factor
      {
            printf("MULTIPLICACION\n");
      }
      |termino OP_DIV factor  
      {
            printf("DIVISION\n");
      }
      ;

factor: 
      ID
      {
            if(!existe_simbolo($<str_val>1)){
                  printf("NO SE DECLARO LA VARIABLE - %s - EN LA SECCION DE DEFINICIONES\n",$<str_val>1);
                  yyerror();
            }
            ultima_expresion = simbolo_busqueda.tipo_dato;
            printf("VARIABLE USADA: %s\n", $<str_val>1);
      }
      |ENTERO 
      {
            guardar_cte_int($<int_val>1);
            ultima_expresion = "int";
            printf("CONSTANTE ENTERA: %d\n",$<int_val>1);
      }
      |REAL
      {
            float valor = $<real_val>1;
            guardar_cte_float(valor);
            ultima_expresion = "float";  
            printf("CONSTANTE REAL: %f\n",valor);
      }
      |P_A expresion P_C
      ;

%%
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL){
	  printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else{
    crearTabla();
    array_nombres_variables = malloc(sizeof(char*)* INITIAL_CAPACITY);
    array_size = INITIAL_CAPACITY;
    free(array_nombres_variables);
    yyparse();
    guardar_ts();
  }
  fclose(yyin);
  return 0;
}
int yyerror(void){
  printf("Syntax Error\n");
  system ("Pause");
  exit (1);
}