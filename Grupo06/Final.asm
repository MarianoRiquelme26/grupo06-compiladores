
INCLUDE macros2.asm		 ;incluye macros
INCLUDE number.asm		 ;incluye el asm para impresion de numeros

.MODEL LARGE		 ; tipo del modelo de memoria usado.
.386
.387
.STACK 200h		 ; bytes en el stack
	
.DATA		 ; comienzo de la zona de datos.
	TRUE equ 1
	FALSE equ 0
	MAXTEXTSIZE equ 32
	suma dd 0.0
	actual dd 0.0
	contador db MAXTEXTSIZE dup(?), '$'
	&cte1 db _Prueba aakflkafhalfl, '$', 11 dup(?)
	&cte2 db _Hola, '$', 27 dup(?)
	&cte3 dd 0
	&cte4 dd 02.5
	&cte5 dd 0.0
	&cte6 db _Otra, '$', 27 dup(?)
	&cte7 dd 9
	&cte8 dd 1
	&cte9 dd 0.342
	&cte10 db _La suma es: , '$', 19 dup(?)
	&cte11 dd 10
	&cte12 db _actual es mayor que 2 , '$', 9 dup(?)
	&cte13 db _no es mayor que 2, '$', 14 dup(?)
	@aux0 dd 0.0
	@aux1 dd 0.0
	@aux2 dd 0.0
	@aux3 dd 0.0
	@aux4 dd 0.0
	@aux5 dd 0.0
	@aux7 dd 0.0
	@aux8 dd 0.0
	@aux9 dd 0.0
	@aux10 dd 0.0
	@aux11 dd 0.0
	@aux12 dd 0.0
	@aux13 dd 0.0
	@aux14 dd 0.0
	@aux15 dd 0.0
	@aux16 dd 0.0
	@aux18 dd 0.0
	@aux19 dd 0.0
	@aux20 dd 0.0
	@aux21 dd 0.0
	@aux23 dd 0.0
	@aux24 dd 0.0
	@aux25 dd 0.0
	@aux26 dd 0.0
	@aux27 dd 0.0
	@aux28 dd 0.0
	@aux29 dd 0.0
	@aux30 dd 0.0
	@aux31 dd 0.0
	@aux32 dd 0.0
	@aux33 dd 0.0
	@aux34 dd 0.0
	@aux35 dd 0.0
	@aux36 dd 0.0
	@aux37 dd 0.0
	@aux38 dd 0.0
	@aux40 dd 0.0
	@aux41 dd 0.0
	@aux42 dd 0.0
	@aux43 dd 0.0
	@aux45 dd 0.0
	@aux46 dd 0.0
	@aux47 dd 0.0
	@aux48 dd 0.0
	@aux49 dd 0.0
	@aux50 dd 0.0
	@aux51 dd 0.0
	@aux52 dd 0.0
	@aux53 dd 0.0
	@aux54 dd 0.0
	@aux55 dd 0.0
	@aux56 dd 0.0
	@aux57 dd 0.0

.CODE ;Comienza sector de codigo
START: 		;Codigo assembler resultante.
	mov AX,@DATA 		;Comienza sector de datos
	mov DS,AX
	finit

	;PUT
	PutString &cte1
	newLine 1

	;PUT
	PutString &cte2
	newLine 1

	;GET
	GetFloat actual



ETIQ_inicio_6:
	;ASIGNACIÓN
	fld &cte3
	fstp contador

	;SUMA
	fld &cte4
	fld &cte5
	fadd
	fstp @aux12

	;ASIGNACIÓN
	fld @aux12
	fstp suma

	;PUT
	PutString &cte6
	newLine 1



ETIQ_inicio_repeat_17:
	;CMP
	fld contador
	fld &cte7
	fcomp
	fstsw ax
	fwait
	sahf

	jbe ETIQ_fin_iteracion_39


ETIQ_inicio_22:
	;SUMA
	fld contador
	fld &cte8
	fadd
	fstp @aux25

	;ASIGNACIÓN
	fld @aux25
	fstp contador

	;DIVISION
	fld contador
	fld &cte9
	fdiv
	fstp @aux30

	;ASIGNACIÓN
	fld @aux30
	fstp actual

	;SUMA
	fld suma
	fld actual
	fadd
	fstp @aux35

	;ASIGNACIÓN
	fld @aux35
	fstp suma

	jmp ETIQ_inicio_repeat_17


ETIQ_fin_iteracion_39:
	;PUT
	PutString &cte10
	newLine 1

	;PUT
	PutFloat suma 
	newLine 1



ETIQ_inicio_44:
	;CMP
	fld actual
	fld &cte11
	fcomp
	fstsw ax
	fwait
	sahf

	ja ETIQ_fin_decision_58
	;CMP
	fld actual
	fld &cte3
	fcomp
	fstsw ax
	fwait
	sahf

	jne ETIQ_fin_decision_58
	;PUT
	PutString &cte12
	newLine 1

	;PUT
	PutString &cte13
	newLine 1

	jmp ETIQ_fin_decision_58


ETIQ_fin_decision_58:

TERMINAR: ;Fin de ejecución.
	mov ax, 4C00h ;termina la ejecución.
	int 21h ;syscall

END START ;final del archivo.