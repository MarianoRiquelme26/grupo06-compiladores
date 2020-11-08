#include "../files_h/pila.h"

void crear_pila(t_pila *pp)
{
    *pp = NULL;
}

int pila_vacia(const t_pila *pp)
{
    if (!*pp)
        return PILA_VACIA;
    else
        return PILA_LLENA;
}

int pila_llena(const t_pila *pp)
{
    t_nodo *aux = (t_nodo *)malloc(sizeof(t_nodo));
    free(aux);
    return !aux;
}

int poner_en_pila(t_pila *pp, const void *dato)
{
    t_nodo *nue = (t_nodo *)malloc(sizeof(t_nodo));
    if (!nue)
        return PILA_LLENA;
    nue->dato = malloc(10);
    memcpy(nue->dato, dato, 10);
    nue->psig = *pp;
    *pp = nue;

    return TODO_OK;
}

int sacar_de_pila(t_pila *pp, void *dato)
{
    t_nodo *aux = *pp;
    if (!*pp)
        return PILA_VACIA;
    memcpy(dato, aux->dato, 10);
    *pp = aux->psig;
    free(aux->dato);
    free(aux);
    return TODO_OK;
}

int tope_pila(const t_pila *pp, void *dato)
{
    if (!*pp)
        return PILA_VACIA;
    memcpy(dato, (*pp)->dato, 10);
    return TODO_OK;
}

void vaciar_pila(t_pila *pp)
{
    t_nodo *aux;
    while (*pp)
    {
        aux = *pp;
        *pp = (*pp)->psig;
        free(aux);
    }
}
