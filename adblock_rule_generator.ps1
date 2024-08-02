# AdBlock Rule Generator

# 定义广告过滤器URL列表
$urlList = @(
    "https://anti-ad.net/adguard.txt",
    "https://anti-ad.net/easylist.txt",
    # ... (其他URL保持不变)
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt"
)

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 第一步：遍历每个广告过滤器URL，下载并提取拦截域名规则
$webClient = New-Object System.Net.WebClient
$webClient.Encoding = [System.Text.Encoding]::UTF8
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

foreach ($url in $urlList) {
    Write-Host "正在处理: $url"
    try {
        $content = $webClient.DownloadString($url)
        $lines = $content -split "`n"

        foreach ($line in $lines) {
            if ($line -match '^\|\|([a-zA-Z0-9.-]+)\^') {
                $domain = $Matches[1]
                $uniqueRules.Add($domain) | Out-Null
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_"
    }
}

# 第二步：去除无效域名规则
$validRules = [System.Collections.Generic.HashSet[string]]::new()
foreach ($rule in $uniqueRules) {
    if ($rule -match '^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$') {
        $validRules.Add($rule) | Out-Null
    }
}

# 第三步：将有效规则格式化为payload列表的格式
$formattedRules = $validRules | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }

# 第四步：生成YAML文件内容
$yamlContent = @"
payload:
$($formattedRules -join "`n")
"@

# 第五步：保存生成的YAML文件
$outputPath = "adblock_reject.yaml"
$yamlContent | Out-File -FilePath $outputPath -Encoding utf8

# 第六步：统计生成的规则条目数量
$ruleCount = $validRules.Count
Write-Host "生成的有效规则总数: $ruleCount"
