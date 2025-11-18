Write-Host "Parando o serviço de spooler..." 
Stop-Service -Name Spooler -Force  
Start-Sleep -Seconds 3 
Write-Host "Limpando arquivos da fila de impressão..." 
$spoolFolder = "C:\Windows\System32\spool\PRINTERS"
Remove-Item "$spoolFolder\*" -Force -Recurse -ErrorAction SilentlyContinue 


Write-Host "Iniciando o serviço de spooler..." 
Start-Service -Name Spooler 
pause