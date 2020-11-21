Segunda.exe Prueba.txt
pause
tasm /la /zi Final.asm
pause
REM tasm /la /zi numbers.asm
tlink /3 Final.obj numbers.obj /v /s /m
pause
del FINAL.OBJ
del FINAL.MAP
del FINAL.LST