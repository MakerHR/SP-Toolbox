<# =============================================================
   Script: Clear-PrintSpooler.ps1
   Objetivo: limpar fila de impressão com máxima compatibilidade
   Compatibilidade: PowerShell 2.0+
   Requisitos: ser administrador
   ============================================================= #>

# Função simples de log compatível com PS v2.0
function Write-Log($Text) {
    Write-Host ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $Text)
}

# Verifica se está em modo admin
Write-Log "Verificando privilégios administrativos..."
$IsAdmin = $false
try {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    $IsAdmin  = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {}

if (-not $IsAdmin) {
    Write-Log "ERRO: Este script precisa ser executado como administrador."
    Write-Log "Saindo..."
    pause
    exit 1
}

# Nome do serviço
$ServiceName = "Spooler"
$SpoolFolder = "$env:SystemRoot\System32\spool\PRINTERS"

# Para serviço
Write-Log "Parando serviço de spooler..."
try {
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Log "Serviço parado com sucesso."
    } else {
        Write-Log "Aviso: Serviço não encontrado ou não disponível."
    }
} catch {
    Write-Log "Aviso: Não foi possível parar o serviço. Detalhes: $($_.Exception.Message)"
}

# Aguardar para garantir liberação de arquivos
Start-Sleep -Seconds 3

# Remove arquivos se existir path
Write-Log "Limpando arquivos da fila..."
try {
    if (Test-Path $SpoolFolder) {
        # Remove somente se houver arquivos para evitar erro
        $items = @(Get-ChildItem $SpoolFolder -Force -ErrorAction SilentlyContinue)
        if ($items.Count -gt 0) {
            Remove-Item "$SpoolFolder\*" -Force -Recurse -ErrorAction SilentlyContinue
            Write-Log "Arquivos da fila removidos."
        } else {
            Write-Log "Nenhum arquivo encontrado para remoção."
        }
    } else {
        Write-Log "Aviso: Caminho do spool não encontrado!"
    }
} catch {
    Write-Log "Aviso: Não foi possível remover arquivos: $($_.Exception.Message)"
}

# Tentar iniciar serviço
Write-Log "Iniciando serviço de spooler..."
try {
    Start-Service -Name $ServiceName -ErrorAction Stop
    Write-Log "Serviço iniciado com sucesso."
} catch {
    Write-Log "ERRO: Falha ao iniciar o serviço. Tentando reparo..."

    # Tentativa de fallback usando sc.exe
    try {
        sc.exe start spooler | Out-Null
        Write-Log "Serviço iniciado via método alternativo."
    } catch {
        Write-Log "ERRO crítico: não foi possível iniciar o spooler!"
    }
}

Write-Log "Processo concluído."
pause
