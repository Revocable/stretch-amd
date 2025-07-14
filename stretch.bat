@echo off
title Esticador de Video v9 - VBR Correto

:: =================================================================================
:: Script v9 (VBR Correto) para esticar vídeos para 1920x1080.
::
:: OBJETIVO: Equilíbrio ideal entre TAMANHO DE ARQUIVO e QUALIDADE.
::
:: CORREÇÃO:
:: - Removido o comando "-rc vbr", que não é suportado pelo encoder hevc_amf.
:: - Para ativar o modo VBR, basta definir o bitrate alvo (-b:v) e o máximo
::   (-maxrate). O encoder assume o modo VBR automaticamente.
:: =================================================================================

cls

:: --- VERIFICAÇÕES INICIAIS ---
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: FFmpeg nao foi encontrado!
    pause
    exit
)
if "%~1"=="" (
    echo ERRO: Nenhum arquivo foi fornecido. Arraste um ou mais vídeos.
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


:: --- O COMANDO DO FFmpeg COM VBR CORRETO ---
ffmpeg -hwaccel d3d11va -i "%~1" -vf "scale=w=1920:h=1080,setsar=1,setdar=16/9" -c:v hevc_amf -b:v 20M -maxrate 30M -quality balanced -c:a copy "%~dpn1_stretched_vbr%~x1"


:: --- VERIFICAÇÃO DE SUCESSO ---
if %errorlevel% neq 0 (
    echo.
    echo # ERRO: A conversao de "%~nx1" falhou! Pulando para o proximo... #
) else (
    echo.
    echo # "%~nx1" concluido com sucesso! #
)


:: --- CONTROLE DO LOOP ---
SHIFT
goto ProcessLoop


:: --- FINALIZAÇÃO ---
:AllDone
echo.
echo.
echo -------------------------------------------------------------
echo # Processo concluido para todos os arquivos!                #
echo -------------------------------------------------------------
echo.
pause
