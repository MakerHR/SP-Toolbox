# Script: LimparCacheDNS.ps1
# Descrição: Limpa o cache DNS do Windows e exibe mensagens de status

try {
    Write-Host "Iniciando limpeza do cache DNS..." -ForegroundColor Cyan

    # Comando para limpar o cache DNS
    ipconfig /flushdns | Out-Null

    Write-Host "Cache DNS limpo com sucesso!" -ForegroundColor Green

    # Exibir o cache DNS atual (opcional)
   # Write-Host "Exibindo o cache DNS atual:" -ForegroundColor Cyan
    #ipconfig /displaydns
}
catch {
    Write-Host "Ocorreu um erro ao tentar limpar o cache DNS:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Pausa para o usuário ver a saída antes de fechar
Read-Host "Pressione ENTER para sair"
