c:\GnuWin32\GnuWin32\bin\flex asd.l
c:\GnuWin32\GnuWin32\bin\bison -dyv sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o compilador.exe
pause
pause
compilador.exe programa.txt

del lex.yy.c
del compilador.exe
del y.tab.c
del y.tab.h
del y.output
pause