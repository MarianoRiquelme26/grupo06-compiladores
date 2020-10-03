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
%token OP_REST
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
      DEFVAR declaraciones ENDDEF
      {
            printf("DECLARACIONES OK\n");
      }
      ;

declaraciones:
      declaraciones declaracion
      |declaracion
      ;

declaracion:
      tipo_variable D_P lista_id
      {
        guardar_variables_ts();
      }
      ;

tipo_variable:
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

lista_id:
      lista_id PYC ID
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
      |between
      {
            printf("BETWEEN\n");
      }
      |salida
      |entrada
      ;

salida:
      DISPLAY ENTERO
      {
            //guardar_cte_int($<int_val>2);
            printf("DISPLAY %d\n",$<int_val>2);
      }
      |DISPLAY REAL
      {
            //guardar_cte_float($<real_val>2);
            printf("DISPLAY %f\n",$<real_val>2);
      }
      |DISPLAY CADENA
      {
            //guardar_cte_string($<str_val>2);
            printf("DISPLAY %s\n",$<str_val>2);
      }
      |DISPLAY ID
      {
            if(!existe_simbolo($<str_val>2)){
                  printf("NO SE DECLARO LA VARIABLE - %s - EN LA SECCION DE DEFINICIONES\n",$<str_val>2);
                  yyerror();
            }
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

between:
      BETWEEN P_A ID COMA C_A expresion PYC expresion C_C P_C
      ;

asignacion: 
      ID ASIG expresion
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
      |ID operador ASIG expresion
      {
            printf("ASIGNACION ESPECIAL EXITOSA!\n");
      }
      |ID ASIG CADENA
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
      |OP_RESTA
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
      OP_L_GT
      |OP_L_GET
      |OP_L_LET
      |OP_L_LT
      |OP_L_E
      |OP_L_NE
      ;

		
expresion:
      termino
      |expresion OP_RESTA termino
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