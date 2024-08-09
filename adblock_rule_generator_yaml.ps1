# (保持URL列表和其他初始设置不变)

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 预编译正则表达式
$domainRegex1 = [regex]::new('^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$domainRegex2 = [regex]::new('^(0\.0\.0\.0|127\.0\.0\.1) ([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$domainRegex3 = [regex]::new('^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$validDomainRegex = [regex]::new('^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# 创建WebClient对象用于下载URL内容
$webClient = New-Object System.Net.WebClient
$webClient.Encoding = [System.Text.Encoding]::UTF8
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

foreach ($url in $urlList) {
    Write-Host "正在处理: $url"
    Add-Content -Path $logFilePath -Value "正在处理: $url"
    try {
        $content = $webClient.DownloadString($url)
        $lines = $content -split "`n"

        foreach ($line in $lines) {
            $domain = $null
            if ($domainRegex1.IsMatch($line)) {
                $domain = $domainRegex1.Match($line).Groups[1].Value
            } elseif ($domainRegex2.IsMatch($line)) {
                $domain = $domainRegex2.Match($line).Groups[2].Value
            } elseif ($domainRegex3.IsMatch($line)) {
                $domain = $domainRegex3.Match($line).Groups[1].Value
            }

            if ($domain -and $validDomainRegex.IsMatch($domain)) {
                $uniqueRules.Add($domain) | Out-Null
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
}

# (保持后续的YAML生成和输出逻辑不变)
