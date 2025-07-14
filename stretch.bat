@echo off
title Esticador de Video v5 - Multi-Arquivos

:: =================================================================================
:: Script v5 (Multi-Arquivo) para esticar vídeos para 1920x1080.
::
:: NOVIDADE:
:: - Suporte a múltiplos arquivos! Arraste quantos vídeos quiser sobre o script.
:: - Utiliza um loop (SHIFT/GOTO) para processar cada arquivo sequencialmente.
:: - Fornece feedback no console para cada arquivo iniciado e concluído.
::
:: ESTRATÉGIA (por arquivo):
:: - GPU decodifica, CPU redimensiona, GPU codifica (abordagem híbrida rápida).
:: - Força o esticamento para 16:9 usando os filtros "setsar" e "setdar".
:: =================================================================================

cls

:: --- VERIFICAÇÃO INICIAL ---
:: Verifica se o FFmpeg existe
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: FFmpeg nao foi encontrado!
    pause
    exit
)

:: Verifica se PELO MENOS UM arquivo foi arrastado
if "%~1"=="" (
    echo ERRO: Nenhum arquivo foi fornecido.
    echo Por favor, arraste um ou mais arquivos de video sobre este script.
    pause
    exit
)


:: --- INÍCIO DO LOOP ---
:ProcessLoop

:: Se a lista de arquivos estiver vazia, pula para o final.
if "%~1"=="" goto AllDone

echo.
echo =============================================================
echo Processando arquivo: "%~nx1"
echo =============================================================
echo.


:: --- O COMANDO DO FFmpeg (o mesmo da v4) ---
ffmpeg -hwaccel d3d11va -i "%~1" -vf "scale=w=1920:h=1080,setsar=1,setdar=16/9" -c:v hevc_amf -quality speed -c:a copy "%~dpn1_stretched_final%~x1"


:: --- VERIFICAÇÃO DE SUCESSO PARA O ARQUIVO ATUAL ---
if %errorlevel% neq 0 (
    echo.
    echo # ERRO: A conversao de "%~nx1" falhou! Pulando para o proximo... #
) else (
    echo.
    echo # "%~nx1" concluido com sucesso! #
)


:: --- CONTROLE DO LOOP ---
:: Move a lista de arquivos para a esquerda (o arquivo %2 se torna o %1)
SHIFT

:: Volta para o início do loop para processar o próximo arquivo
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
