c:\GnuWin32\bin\flex Lexico.l
c:\GnuWin32\bin\bison -dyv Sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c files_c\ts.c files_c\tercetos.c files_c\pila.c -o Segunda.exe
pause
pause
Segunda.exe prueba.txt

del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
pause