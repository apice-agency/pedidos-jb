@echo off
setlocal
title Actualizar precios en GitHub y Vercel

REM Ejecutar desde la carpeta donde esta este .bat.
cd /d "%~dp0"

echo.
echo ==========================================
echo   ACTUALIZAR PRECIOS.XLSX
echo ==========================================
echo.

REM Verificar que esta dentro de un repositorio Git.
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo ERROR: Esta carpeta no pertenece a un repositorio Git.
    echo Coloca este .bat en la carpeta principal del proyecto.
    echo.
    pause
    exit /b 1
)

REM Verificar que exista el Excel.
if not exist "precios.xlsx" (
    echo ERROR: No se encuentra precios.xlsx en esta carpeta:
    echo "%~dp0"
    echo.
    pause
    exit /b 1
)

REM Obtener la rama actual.
for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if not defined BRANCH (
    echo ERROR: No se pudo detectar la rama actual.
    echo Asegurate de estar en una rama Git, por ejemplo main.
    echo.
    pause
    exit /b 1
)

echo Agregando precios.xlsx...
git add -- "precios.xlsx"
if errorlevel 1 (
    echo ERROR: Git no pudo agregar precios.xlsx.
    echo.
    pause
    exit /b 1
)

REM Si no hay cambios en el Excel, no crear un commit vacio.
git diff --cached --quiet -- "precios.xlsx"
if not errorlevel 1 (
    echo.
    echo No hay cambios nuevos en precios.xlsx para subir.
    echo GitHub y Vercel no necesitan actualizarse.
    echo.
    pause
    exit /b 0
)

echo.
set /p "MENSAJE=Comentario del cambio (Enter para usar 'Actualizar precios'): "
if not defined MENSAJE set "MENSAJE=Actualizar precios"

echo.
echo Creando commit...
git commit -m "%MENSAJE%"
if errorlevel 1 (
    echo.
    echo ERROR: No se pudo crear el commit.
    echo Revisa la configuracion de Git y vuelve a intentarlo.
    echo.
    pause
    exit /b 1
)

echo.
echo Subiendo cambios a GitHub (rama %BRANCH%)...
git push origin "%BRANCH%"
if errorlevel 1 (
    echo.
    echo ERROR: No se pudo subir a GitHub.
    echo Revisa tu conexion, permisos y autenticacion de GitHub.
    echo El commit local se conserva; puedes volver a ejecutar este .bat.
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   LISTO: precios.xlsx subido a GitHub
echo ==========================================
echo Vercel deberia iniciar el deploy automaticamente.
echo Revisa el estado del deploy en el panel de Vercel.
echo.
pause
endlocal
