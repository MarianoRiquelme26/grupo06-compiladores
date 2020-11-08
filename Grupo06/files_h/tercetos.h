
#ifndef TERCETO_H
#define TERCETO_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "constantes.h"

struct struct_Terceto
{
    char operador[100];
    char operandoIzq[100];
    char operandoDer[100];
};
struct struct_Terceto tercetos[10000];

int crearTerceto(char *, char *, char *);
int modificarTerceto(int, int, char *);
char *obtenerTerceto(int, int);
char *armarIndiceI(int);
char *armarIndiceD(int);
int desarmarIndice(char *);
void removeChars(char *, char);
int obtenerIndiceActual();
int crearArchivoTercetosIntermedia();
void imprimirTercetos();

#endif
