# Lista de DNS a testar
$dnsServers = @{
    "Google 1"     = "8.8.8.8"
    "Google 2"     = "8.8.4.4"
    "Cloudflare 1" = "1.1.1.1"
    "Cloudflare 2" = "1.0.0.1"
    "Quad9"        = "9.9.9.9"
    "OpenDNS 1"    = "208.67.222.222"
    "OpenDNS 2"    = "208.67.220.220"
}

# Lista de domínios para benchmark
$testDomains = @("google.com.br", "microsoft.com.br", "cloudflare.com.br", "wikipedia.org.br", "facebook.com.br", "youtube.com.br")

Write-Host "Testando servidores DNS com múltiplos domínios..." -ForegroundColor Blue
Write-Host ""

$results = @()

foreach ($name in $dnsServers.Keys) {
    $server = $dnsServers[$name]
    $times = @()

    foreach ($domain in $testDomains) {
        try {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Resolve-DnsName -Server $server -Name $domain -ErrorAction Stop | Out-Null
            $sw.Stop()

            $times += $sw.ElapsedMilliseconds
            Write-Host "$name ($server) respondeu $domain em $($sw.ElapsedMilliseconds) ms" -ForegroundColor Gray
        }
        catch {
            Write-Host "$name ($server) falhou ao resolver $domain" -ForegroundColor Red
        }
    }

    if ($times.Count -gt 0) {
        $avg = [math]::Round(($times | Measure-Object -Average).Average,2)
        $results += [PSCustomObject]@{
            Servidor = $name
            IP       = $server
            MediaMs  = $avg
        }
        Write-Host "$name ($server) média: $avg ms" -ForegroundColor DarkYellow
        Write-Host ""
    }
}

if ($results.Count -gt 0) {
    $best = $results | Sort-Object MediaMs | Select-Object -First 1
    Write-Host ""
    Write-Host ("Melhor DNS: {0} ({1}) com média de {2} ms" -f $best.Servidor, $best.IP, $best.MediaMs) -ForegroundColor Green
}
    Write-Host ""
	    Write-Host ""
Read-Host "Pressione ENTER para sair"
