# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash

# 定义广告过滤器URL列表
$urlList = @(
    "https://anti-ad.net/adguard.txt",
    "https://anti-ad.net/easylist.txt",
    # 添加更多URL
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
            # 第一种情况：需要加上前缀 '+.' 和后缀 '' 的情况
            if ($line -match '^(\|\|\*?\.example\.com\^$|example\.com|/^[a-z0-9-]+\.example\.com$/|address=/example\.com/127\.0\.0\.1|address=/example\.com/0\.0\.0\.0)') {
                $domain = $Matches[1]
                $formattedRule = "+.$domain+"
                $uniqueRules.Add($formattedRule) | Out-Null
            }
            # 第二种情况：需要加上前缀 '' 和后缀 '' 的情况
            elseif ($line -match '^(\|\|example\.com\^$|/^\|\|example\.com\^$|/^\|\|example\.com\^\$|/^\|\|example\.com\^\$all|/^example\.com$/|/^\|\|example\.com\^\$|127\.0\.0\.1 example\.com|0\.0\.0\.0 example\.com)') {
                $domain = $Matches[1]
                $formattedRule = "$domain"
                $uniqueRules.Add($formattedRule) | Out-Null
            }
            # 第三种情况：忽略条目
            elseif ($line -match '^@@\|\|example\.com\^') {
                continue
            }
        }
    }
    catch 
    {
        Write-Host "无法处理URL: $url"
        Add-Content -Path $logFilePath -Value "无法处理URL: $url"
    }
}

# 对规则进行排序
$formattedRules = $uniqueRules | Sort-Object

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
