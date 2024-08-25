# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash

# 定义广告过滤器URL列表
$urlList = @(
"https://anti-ad.net/adguard.txt",
"https://anti-ad.net/easylist.txt",
# ... (省略其他URL)
"https://raw.githubusercontent.com/brave/adblock-lists/master/brave-unbreak.txt"
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 创建WebClient对象用于下载URL内容
$webClient = New-Object System.Net.WebClient
$webClient.Encoding = [System.Text.Encoding]::UTF8
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

foreach ($url in $urlList) 
{
    Write-Host "正在处理: $url"
    Add-Content -Path $logFilePath -Value "正在处理: $url"
    
    try 
    {
        $content = $webClient.DownloadString($url)
        $lines = $content -split "`n"
        
        # 收集所有例外规则的域名
        $exceptionDomains = @()

        foreach ($line in $lines) 
        {
            # 收集@@开头的例外规则
            if ($line -match '^@@\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') 
            {
                $exceptionDomains += $Matches[1]
            }
        }

        foreach ($line in $lines) 
        {
            # 排除注释、空行和例外规则
            if ($line -match '^\s*(#|$)' -or $line -match '^@@') 
            {
                continue
            }

            # 函数：检查是否为有效域名
            function Is-ValidDomain 
            {
                param ([string]$domain)
                return $domain -match '^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}$'
            }

            # 初步筛选匹配的域名
            $domain = ""
            if ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$') 
            {
                $domain = $Matches[1]
            }
            elseif ($line -match '^(0\.0\.0\.0|127\.0\.0\.1)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$') 
            {
                $domain = $Matches[2]
            }
            elseif ($line -match '^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/(?:0\.0\.0\.0|\s*|$)') 
            {
                $domain = $Matches[1]
            }

            # 进行第二步筛选
            if ($domain -ne "" -and Is-ValidDomain $domain) 
            {
                $isException = $exceptionDomains -contains $domain
                
                if (-not $isException) 
                {
                    $uniqueRules.Add($domain) | Out-Null
                }
            }
        }
    } 
    catch 
    {
        Write-Host "处理 $url 时出错: $_"
        Add-Content -Path $logFilePath -Value "处理 $url 时出错: $_"
    }
}

# 对规则进行排序并格式化
$formattedRules = $uniqueRules | Sort-Object | ForEach-Object {"- '+.$_'"}

# 统计生成的规则条目数量
$ruleCount = $uniqueRules.Count

# 获取当前时间并转换为东八区时间
$generationTime = (Get-Date).ToUniversalTime().AddHours(8).ToString("yyyy-MM-dd HH:mm:ss")

# 创建文本格式的字符串
$textContent = @"
# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截规则集，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash
# LICENSE1：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-GPL3.0
# LICENSE2：https://github.com/REIJI007/AdBlock_Rule_For_Clash/blob/main/LICENSE-CC%20BY-NC-SA%204.0
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
Add-Content -Path $logFilePath -Value "Generated at: $generationTime"

Pause
