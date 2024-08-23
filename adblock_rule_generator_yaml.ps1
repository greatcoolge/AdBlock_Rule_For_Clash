# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash

# 定义广告过滤器URL列表
$urlList = @(
    "https://anti-ad.net/adguard.txt",
    "https://anti-ad.net/easylist.txt",
    "https://easylist-downloads.adblockplus.org/easylist.txt",
    "https://easylist-downloads.adblockplus.org/easylistchina.txt",
    "https://easylist-downloads.adblockplus.org/easyprivacy.txt"
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建两个HashSet来存储唯一的规则
$domainRules = [System.Collections.Generic.HashSet[string]]::new()
$domainSuffixRules = [System.Collections.Generic.HashSet[string]]::new()

# 创建WebClient对象用于下载URL内容
$webClient = New-Object System.Net.WebClient
$webClient.Encoding = [System.Text.Encoding]::UTF8
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
            # 清除空格和转义字符
            $line = $line.Trim()

            # Adblock/Easylist 格式的完整域名 (添加 DOMAIN 前缀)
            if ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') {
                $domain = $Matches[1]
                $domainRules.Add("DOMAIN,$domain") | Out-Null
            }
            # Adblock/Easylist 格式的子域名 (添加 DOMAIN-SUFFIX 前缀)
            elseif ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                $domain = $Matches[1]
                $domainSuffixRules.Add("DOMAIN-SUFFIX,$domain") | Out-Null
            }
            # Hosts 文件格式的完整域名 (添加 DOMAIN 前缀)
            elseif ($line -match '^(0\.0\.0\.0|127\.0\.0\.1)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                $domain = $Matches[2]
                $domainRules.Add("DOMAIN,$domain") | Out-Null
            }
            # Hosts 文件格式的子域名 (添加 DOMAIN-SUFFIX 前缀)
            elseif ($line -match '^(0\.0\.0\.0|127\.0\.0\.1)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                $domain = $Matches[2]
                $domainSuffixRules.Add("DOMAIN-SUFFIX,$domain") | Out-Null
            }
            # Dnsmasq/AdGuard 格式的完整域名 (添加 DOMAIN 前缀)
            elseif ($line -match '^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$') {
                $domain = $Matches[1]
                $domainRules.Add("DOMAIN,$domain") | Out-Null
            }
            # Dnsmasq/AdGuard 格式的子域名 (添加 DOMAIN-SUFFIX 前缀)
            elseif ($line -match '^address=/([a-zA-Z0-9-]+\.[a-zA-Z]{2,})/$') {
                $domain = $Matches[1]
                $domainSuffixRules.Add("DOMAIN-SUFFIX,$domain") | Out-Null
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
}

# 对规则进行排序并添加前缀
$formattedDomainRules = $domainRules | Sort-Object | ForEach-Object { "  - $_" }
$formattedDomainSuffixRules = $domainSuffixRules | Sort-Object | ForEach-Object { "  - $_" }

# 合并规则列表
$allFormattedRules = $formattedDomainRules + $formattedDomainSuffixRules

# 统计生成的规则条目数量
$ruleCount = $allFormattedRules.Count

# 获取当前东八区时间
$timeZoneInfo = [System.TimeZoneInfo]::FindSystemTimeZoneById("China Standard Time")
$localTime = [System.TimeZoneInfo]::ConvertTime([System.DateTime]::UtcNow, $timeZoneInfo)
$generatedTime = $localTime.ToString("yyyy-MM-dd HH:mm:ss")

# 创建文本格式的字符串
$textContent = @"
# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash
# LICENSE1：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-GPL3.0
# LICENSE2：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-CC%20BY-NC-SA%204.0
# Generated AdBlock rules
# Generated on: $generatedTime (GMT+8)
# Total entries: $ruleCount

payload:
$($allFormattedRules -join "`n")
"@

# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
$textContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"
Add-Content -Path $logFilePath -Value "生成的有效规则总数: $ruleCount"

Pause
