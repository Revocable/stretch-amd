@echo off
title Esticador de Video v4 - Final (AMD/CPU)

:: =================================================================================
:: Script v4 (Final) para esticar um vídeo para 1920x1080.
::
:: ESTRATÉGIA FINAL:
:: - GPU decodifica, CPU redimensiona, GPU codifica (abordagem híbrida rápida).
:: - CORREÇÃO: Adicionados os filtros "setsar" e "setdar" para FORÇAR
::   o esticamento da imagem e ignorar a proporção original.
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
    echo ERRO: Nenhum arquivo foi fornecido. Arraste um video sobre o script.
    pause
    exit
)


:: --- PROCESSAMENTO DO VÍDEO ---

echo Arquivo de Entrada: "%~nx1"
echo.
echo Iniciando o processo FINAL (Hibrido + Esticado) de conversao...
echo.

:: Comando FFmpeg Final
:: -hwaccel d3d11va                   -> GPU decodifica.
:: -i "%~1"                           -> Arquivo de entrada.
:: -vf "scale=w=1920:h=1080,setsar=1,setdar=16/9" -> A MÁGICA: Redimensiona E força o esticamento para 16:9.
:: -c:v hevc_amf                      -> GPU codifica.
:: -quality speed                     -> Preset de velocidade.
:: -c:a copy                          -> Copia o áudio.
:: "%~dpn1_stretched_final%~x1"       -> Arquivo de saída com novo nome.

ffmpeg -hwaccel d3d11va -i "%~1" -vf "scale=w=1920:h=1080,setsar=1,setdar=16/9" -c:v hevc_amf -quality speed -c:a copy "%~dpn1_stretched%~x1"


:: --- VERIFICAÇÃO DE SUCESSO ---
if %errorlevel% neq 0 (
    echo.
    echo #############################################################
    echo #  ERRO: A conversao do FFmpeg falhou!                       #
    echo #  Verifique as mensagens de erro no console acima.          #
    echo #############################################################
) else (
    echo.
    echo -------------------------------------------------------------
    echo #  Processo concluido com sucesso!                          #
    echo -------------------------------------------------------------
)

echo.
pause