# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截rule-providers，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash

# 定义广告过滤器URL列表
$urlList = @(
    # ... (保持URL列表不变)
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建一个并发字典来存储唯一的规则
$uniqueRules = [System.Collections.Concurrent.ConcurrentDictionary[string,byte]]::new()

# 预编译正则表达式
$domainRegex = [regex]::new('(?:^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^|^(?:0\.0\.0\.0|127\.0\.0\.1) ([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/)', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$validDomainRegex = [regex]::new('^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# 并行处理URL
$urlList | ForEach-Object -Parallel {
    $url = $_
    $uniqueRules = $using:uniqueRules
    $domainRegex = $using:domainRegex
    $validDomainRegex = $using:validDomainRegex
    $logFilePath = $using:logFilePath

    Write-Host "正在处理: $url"
    Add-Content -Path $logFilePath -Value "正在处理: $url"
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Encoding = [System.Text.Encoding]::UTF8
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        $content = $webClient.DownloadString($url)
        
        $domainRegex.Matches($content) | ForEach-Object {
            $domain = $_.Groups[1].Value + $_.Groups[2].Value + $_.Groups[3].Value
            if ($validDomainRegex.IsMatch($domain)) {
                $uniqueRules.TryAdd($domain, 0) | Out-Null
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
} -ThrottleLimit 10

# 对规则进行排序并添加DOMAIN,前缀
$formattedRules = $uniqueRules.Keys | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }

# 统计生成的规则条目数量
$ruleCount = $uniqueRules.Count

# 创建YAML格式的字符串
$yamlContent = @"
# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截rule-providers，同时提供兼容Surge的规则集配置，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash
# LICENSE1：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-GPL3.0
# LICENSE2：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-CC%20BY-NC-SA%204.0

# Generated AdBlock rules
# Total entries: $ruleCount

payload:
$($formattedRules -join "`n")
"@

# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
$yamlContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"
Add-Content -Path $logFilePath -Value "生成的有效规则总数: $ruleCount"

Pause
