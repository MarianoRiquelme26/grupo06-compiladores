#ifndef TS_H
#define TS_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "constantes.h"

// Tabla de simbolos
struct struct_tablaSimbolos
{
    char nombre[100];
    char tipo[100];
    char valor[100];
    char longitud[100];
};
struct struct_tablaSimbolos tablaSimbolos[10000];

void insertarTokenEnTS(char *, char *);
int existeTokenEnTS(char *);
char *recuperarNombreTS(char *);
char *recuperarTipoTS(char *);
char *recuperarValorTS(char *);
int crearArchivoTS();
void debugTS();
int obtenerTamTS();
void prepararTSParaAssembler();
void imprimirTS();

#endif
