# 定义广告过滤器URL列表
$urlList = @(
    # (URL 列表省略，保持不变)
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

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
            # 匹配 Adblock/Easylist 格式的规则，包括子域名
            if ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') {
                $domain = $Matches[1]
                $uniqueRules.Add($domain) | Out-Null

                # 提取子域名部分
                if ($domain -match '^([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})$') {
                    $subdomain = '*.' + $Matches[2]
                    $uniqueRules.Add($subdomain) | Out-Null
                }
            }
            # 匹配 Hosts 文件格式的规则
            elseif ($line -match '^(0\.0\.0\.0|127\.0\.0\.1)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                $domain = $Matches[2]
                $uniqueRules.Add($domain) | Out-Null

                # 提取子域名部分
                if ($domain -match '^([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})$') {
                    $subdomain = '*.' + $Matches[2]
                    $uniqueRules.Add($subdomain) | Out-Null
                }
            }
            # 匹配 Dnsmasq/AdGuard 格式的规则
            elseif ($line -match '^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$') {
                $domain = $Matches[1]
                $uniqueRules.Add($domain) | Out-Null

                # 提取子域名部分
                if ($domain -match '^([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})$') {
                    $subdomain = '*.' + $Matches[2]
                    $uniqueRules.Add($subdomain) | Out-Null
                }
            }
            # 匹配通配符匹配格式的规则
            elseif ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') {
                $domain = $Matches[1]
                $uniqueRules.Add($domain) | Out-Null

                # 提取子域名部分
                if ($domain -match '^([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})$') {
                    $subdomain = '*.' + $Matches[2]
                    $uniqueRules.Add($subdomain) | Out-Null
                }
            }
            # 匹配通配符域名，如 *.example.com
            elseif ($line -match '^\*\.([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') {
                $domain = $Matches[1]
                $uniqueRules.Add($domain) | Out-Null
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
}

# 对规则进行排序并添加前缀
$formattedRules = $uniqueRules | Sort-Object | ForEach-Object { "  - '+.$_' " }

# 统计生成的规则条目数量
$ruleCount = $uniqueRules.Count

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
$($formattedRules -join "`n")
"@

# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
$textContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"
Add-Content -Path $logFilePath -Value "生成的有效规则总数: $ruleCount"

Pause
