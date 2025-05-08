# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash
# LICENSE1: https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-GPL3.0
# LICENSE2: https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-CC%20BY-NC-SA%204.0

# 定义广告过滤器URL列表
$urlList = @(
    "https://raw.githubusercontent.com/greatcoolge/adblockfilters1/main/rules/adblockdns.txt"
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建两个HashSet来存储唯一的规则和排除的域名
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()
$excludedDomains = [System.Collections.Generic.HashSet[string]]::new()

# 创建WebClient对象用于下载规则
$webClient = New-Object System.Net.WebClient
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

foreach ($url in $urlList) {
    Write-Host "正在处理: $url"
    Add-Content -Path $logFilePath -Value "正在处理: $url"
    try 
    {
        $content = $webClient.DownloadString($url)
        $lines = $content -split "`n"

        foreach ($line in $lines) 
        {
            # 匹配所有以 @@|| 开头的规则，并提取域名
            if ($line -match '^@@\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})') {
                $excludedDomain = $Matches[1]
                $excludedDomains.Add($excludedDomain) | Out-Null
            }
            else 
            {
                # 匹配 Adblock/Easylist 格式的规则
                if ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') {
                    $domain = $Matches[1]
                    $uniqueRules.Add($domain) | Out-Null
                }
                # 匹配 Hosts 文件格式的规则
                elseif ($line -match '^(0\.0\.0\.0|127\.0\.0\.1)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                    $domain = $Matches[2]
                    $uniqueRules.Add($domain) | Out-Null
                }
                # 匹配 Dnsmasq 格式的规则
                elseif ($line -match '^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$') {
                    $domain = $Matches[1]
                    $uniqueRules.Add($domain) | Out-Null
                }
                # 匹配通配符匹配格式的规则
                elseif ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') {
                    $domain = $Matches[1]
                    $uniqueRules.Add($domain) | Out-Null
                }
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
}

# 排除以 @@|| 开头规则中提取的域名
$finalRules = $uniqueRules | Where-Object { -not $excludedDomains.Contains($_) }

# 去掉注释行（以 # 开头）
$finalRules = $finalRules | Where-Object { $_.Trim() -ne "" -and -not $_.Trim().StartsWith("#") }

# 对规则进行排序并格式化
$formattedRules = $finalRules | Sort-Object | ForEach-Object {"- '+.$_'"}

# 统计生成的规则条目数量
$ruleCount = $finalRules.Count

# 获取当前时间并转换为东八区时间
$generationTime = (Get-Date).ToUniversalTime().AddHours(8).ToString("yyyy-MM-dd HH:mm:ss")

# 创建文本格式的字符串
$textContent = @"
# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/greatcoolge/AdBlock_Rule_For_Clash
# LICENSE1: https://github.com/greatcoolge/AdBlock_Rule_For_Clash/blob/main/LICENSE-GPL3.0
# LICENSE2: https://github.com/greatcoolge/AdBlock_Rule_For_Clash/blob/main/LICENSE-CC%20BY-NC-SA%204.0
# Generated on: $generationTime
# Generated AdBlock rules
# Total entries: $ruleCount

payload:
$($formattedRules -join "`n")
"@

# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
$textContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"
Add-Content -Path $logFilePath -Value "Total entries: $ruleCount"
