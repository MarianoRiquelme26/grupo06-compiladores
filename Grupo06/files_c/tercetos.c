#include "../files_h/tercetos.h"

int tamTercetos = 0;

int crearTerceto(char *operador, char *operando1, char *operando2)
{
    int indiceTercetoCreado = tamTercetos;
    strcpy(tercetos[tamTercetos].operador, operador);
    strcpy(tercetos[tamTercetos].operandoIzq, operando1);
    strcpy(tercetos[tamTercetos].operandoDer, operando2);
    tamTercetos++;
    return indiceTercetoCreado;
}

int modificarTerceto(int indice, int posDentroTerceto, char *valor)
{
    switch (posDentroTerceto)
    {
    case 1:
        strcpy(tercetos[indice].operador, valor);
        break;
    case 2:
        strcpy(tercetos[indice].operandoIzq, valor);
        break;
    case 3:
        strcpy(tercetos[indice].operandoDer, valor);
        break;
    default:
        return ERROR;
    }
    return TODO_OK;
}

char* obtenerTerceto(int indice, int posDentroTerceto)
{
    switch (posDentroTerceto)
    {
    case 1:
        return tercetos[indice].operador;
    case 2:
        return tercetos[indice].operandoIzq;
    case 3:
        return tercetos[indice].operandoDer;
    }
    return NULL;
}

char * armarIndiceI(int intIndice)
{
	static char strIndice[8];
	sprintf(strIndice, "[%d]", intIndice);
	return strIndice;
}

char * armarIndiceD(int intIndice)
{
	static char strIndice[8];
	sprintf(strIndice, "[%d]", intIndice);
	return strIndice;
}

int desarmarIndice(char * indiceStr)
{
    removeChars(indiceStr,'[');
    removeChars(indiceStr,']');
    int r = atoi(indiceStr);
    return r;
}

void removeChars(char *s, char c)
{
    int writer = 0, reader = 0;

    while (s[reader])
    {
        if (s[reader]!=c)
        {
            s[writer++] = s[reader];
        }

        reader++;
    }

    s[writer]=0;
}

int obtenerIndiceActual()
{
    return tamTercetos;
}

int crearArchivoTercetosIntermedia()
{
    FILE *archivo;
    int i;
    archivo = fopen("intermedia.txt", "w");

    if (!archivo)
    {
        return ERROR;
    }

    // Cabecera del archivo
    fprintf(archivo, "Lista de Tercetos\n");

    // Se escribe cada terceto
    for (i = 0; i < tamTercetos; i++)
    {
        fprintf(archivo, "[%d] (%s, %s, %s)\n", i, tercetos[i].operador, tercetos[i].operandoIzq, tercetos[i].operandoDer);
    }
    fclose(archivo);

    return TODO_OK;
}

void imprimirTercetos()
{
    int i;
    for (i = 0; i < tamTercetos; i++)
    {
        printf("[%d] (%s, %s, %s)\n", i, tercetos[i].operador, tercetos[i].operandoIzq, tercetos[i].operandoDer);
    }
}
