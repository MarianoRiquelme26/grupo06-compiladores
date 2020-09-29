c:\GnuWin32\GnuWin32\bin\flex asd.l
pause
c:\MinGW\bin\gcc.exe lex.yy.c -o TPFinal.exe
pause
pause
TPFinal.exe programa.txt

del lex.yy.c
del TPFinal.exe
pause