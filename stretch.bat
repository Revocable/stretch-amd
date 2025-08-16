@echo off
setlocal

title Esticador de Video v10.1 - VBR com Corte Condicional (Corrigido)

:: =================================================================================
:: Script v10.1 (VBR com Corte Condicional - Correção de Bug)
::
:: OBJETIVO:
:: - Para vídeos 1920x1080: Corta o centro (1280x960) e estica para 1920x1080.
:: - Para outras resoluções: Apenas estica para 1920x1080.
:: - Mantém o equilíbrio entre TAMANHO DE ARQUIVO e QUALIDADE com VBR.
::
:: CORREÇÃO v10.1:
:: - Corrigido o erro de parsing do ffprobe dentro do loop FOR.
:: - Argumentos de ffprobe agora estão entre aspas para evitar que o cmd.exe
::   interprete caracteres especiais (= ,) de forma incorreta.
:: =================================================================================

cls

:: --- VERIFICAÇÕES INICIAIS ---
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: FFmpeg nao foi encontrado! Verifique se ele esta no PATH do sistema.
    pause
    exit
)
where ffprobe >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: ffprobe nao foi encontrado! Verifique se ele esta na mesma pasta do ffmpeg.
    pause
    exit
)

if "%~1"=="" (
    echo ERRO: Nenhum arquivo foi fornecido. Arraste um ou mais vídeos para o script.
    pause
    exit
)

:: --- INÍCIO DO LOOP ---
:ProcessLoop
if "%~1"=="" goto AllDone

echo.
echo =============================================================
echo Processando arquivo: "%~nx1"
echo =============================================================
echo.

:: --- DETECTA A RESOLUÇÃO DO VÍDEO (COM CORREÇÃO) ---
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries "stream=width,height" -of "csv=s=x:p=0" "%~1"') do (
    set "VIDEO_RES=%%a"
)

if not defined VIDEO_RES (
    echo ERRO: Nao foi possivel obter a resolucao de "%~nx1". Pulando...
    goto NextFile
)

echo Resolucao detectada: %VIDEO_RES%
echo.

:: --- LÓGICA CONDICIONAL BASEADA NA RESOLUÇÃO ---
if "%VIDEO_RES%"=="1920x1080" (
    echo Resolucao 1920x1080 detectada. Aplicando CORTE + ESTICAMENTO.
    set "OUTPUT_SUFFIX=_cropped_stretched_vbr"
    set "VIDEO_FILTER=crop=1440:1080,scale=w=1920:h=1080,setsar=1,setdar=16/9"
) else (
    echo Resolucao diferente de 1920x1080. Aplicando apenas ESTICAMENTO.
    set "OUTPUT_SUFFIX=_stretched_vbr"
    set "VIDEO_FILTER=scale=w=1920:h=1080,setsar=1,setdar=16/9"
)

:: --- O COMANDO DO FFmpeg COM LÓGICA ADAPTADA ---
ffmpeg -hide_banner -y -hwaccel d3d11va -i "%~1" -vf "%VIDEO_FILTER%" -c:v hevc_amf -b:v 40M -maxrate 60M -quality quality -c:a copy "%~dpn1%OUTPUT_SUFFIX%%~x1"

:: --- VERIFICAÇÃO DE SUCESSO ---
if %errorlevel% neq 0 (
    echo.
    echo # ERRO: A conversao de "%~nx1" falhou! Pulando para o proximo... #
) else (
    echo.
    echo # "%~nx1" concluido com sucesso! #
    echo # Salvo como: "%~nx1%OUTPUT_SUFFIX%%~x1" #
)

:NextFile
:: Limpa a variável de resolução para a próxima iteração
set "VIDEO_RES="

:: --- CONTROLE DO LOOP ---
SHIFT
goto ProcessLoop

:: --- FINALIZAÇÃO ---
:AllDone
echo.
echo.
echo -------------------------------------------------------------
echo # Processo concluido para todos os arquivos!                 #
echo -------------------------------------------------------------
echo.
pause
