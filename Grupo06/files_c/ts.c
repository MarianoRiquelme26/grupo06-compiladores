#include "../files_h/ts.h"

int posicion_en_ts = 0; // Incremento Longitud en la estructura tabla de simbolos

void insertarTokenEnTS(char *tipo, char *nombre)
{
	int i;

	for (i = 0; i < posicion_en_ts; i++)
	{
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0)
		{
			// En caso que el valor exista, sale de la funcion.
			return;
		}
	}
	// En caso que el valor no exista, se agrega a la estructura
	strcpy(tablaSimbolos[posicion_en_ts].tipo, tipo);
	strcpy(tablaSimbolos[posicion_en_ts].nombre, nombre);
	posicion_en_ts++;
}

int obtenerTamTS()
{
	return posicion_en_ts;
}

int existeTokenEnTS(char *nombre)
{
	int i;
	for (i = 0; i < posicion_en_ts; i++)
	{
		if (strcmp(nombre, tablaSimbolos[i].nombre) == 0)
		{
			return EXISTE;
		}
	}
	return NO_EXISTE;
}

char *recuperarTipoTS(char *nombre)
{
	int i;
	for (i = 0; i < posicion_en_ts; i++)
	{
		//printf("Voy a comprar %s con %s \n",nombre, tablaSimbolos[i].nombre);
		if (strcmp(nombre, tablaSimbolos[i].nombre) == 0)
		{
			return tablaSimbolos[i].tipo;
		}
	}
	return ERROR;
}

char *recuperarValorTS(char *nombre)
{
	int i;
	for (i = 0; i < posicion_en_ts; i++)
	{
		if (strcmp(nombre, tablaSimbolos[i].nombre) == 0)
		{
			return tablaSimbolos[i].valor;
		}
	}
	return ERROR;
}

char *recuperarNombreTS(char *valor)
{
	int i;
	for (i = 0; i < posicion_en_ts; i++)
	{
		if (strcmp(valor, tablaSimbolos[i].valor) == 0)
		{
			return tablaSimbolos[i].nombre;
		}
	}
	return ERROR;
}

void debugTS()
{
	int i;
	printf("====== DEBUG TABLA SIMBOLOS ======\n\n");
	printf("La cantidad de elementos es %d \n", posicion_en_ts);
	printf("Lista de elementos: \n");
	for (i = 0; i < posicion_en_ts; i++)
	{
		printf("%d => %s | %s | %s | %s \n", i, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
	}

	printf("\n====== FIN DEBUG TABLA SIMBOLOS ======\n\n");
}

void prepararTSParaAssembler()
{
	int i;
	int contador = 1;
	for (i = 0; i < posicion_en_ts; i++)
	{
		if ((strcmp(tablaSimbolos[i].tipo, "INTEGER") == 0)
		|| (strcmp(tablaSimbolos[i].tipo, "FLOAT") == 0)
		|| (strcmp(tablaSimbolos[i].tipo, "STRING") == 0))
		{
			char nuevoNombre[100] = "";
			strcat(nuevoNombre, tablaSimbolos[i].nombre);
			strcpy(tablaSimbolos[i].nombre, nuevoNombre);

			// solo a fines practicos
			strcpy(tablaSimbolos[i].valor, tablaSimbolos[i].nombre);
		}
		else
		{
			strcpy(tablaSimbolos[i].valor, tablaSimbolos[i].nombre);

			if(strcmp(tablaSimbolos[i].tipo, "CTE_STR") == 0)
			{
				int longitud = strlen(tablaSimbolos[i].valor);

				char longitudStr[10];
				sprintf(longitudStr, "%d", longitud);
				strcpy(tablaSimbolos[i].longitud, longitudStr);

			}

			char nuevoNombreConstantes[10] = "&cte";
			char contadorStr[10];
			sprintf(contadorStr, "%d", contador);
			strcat(nuevoNombreConstantes, contadorStr);
			strcpy(tablaSimbolos[i].nombre, nuevoNombreConstantes);

			contador++;
		}
	}

}

int crearArchivoTS()
{
	FILE *archivo;
	int i;
	archivo = fopen("ts.txt", "w");

	if (!archivo)
	{
		return ERROR;
	}

	// Cabecera del archivo
	fprintf(archivo, "%-30s%-12s%-30s%-12s\n", "Nombre", "Tipo", "Valor", "Longitud");

	// Se escribe linea por linea
	for (i = 0; i < posicion_en_ts; i++)
	{
		if(tablaSimbolos[i].nombre[0] != '_')
		{
			if ((strcmp(tablaSimbolos[i].tipo, "INTEGER") == 0)
			|| (strcmp(tablaSimbolos[i].tipo, "FLOAT") == 0)
			|| (strcmp(tablaSimbolos[i].tipo, "STRING") == 0))
			{
				fprintf(archivo, "%-30s%-12s\n", tablaSimbolos[i].nombre, tablaSimbolos[i].tipo);
			}
			else
			{
				fprintf(archivo, "%-29s%-12s%-30s%-12s\n",
				tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
			}
		}
	}
	fclose(archivo);

	return TODO_OK;
}


void imprimirTS()
{
	int i;
	for (i = 0; i < posicion_en_ts; i++)
	{
		printf("%-29s%-12s%-30s%-12s\n",tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
	}
}
