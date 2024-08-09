# 定义广告过滤器URL列表
$urlList = @(
    "https://anti-ad.net/adguard.txt",
    # 更多 URL...
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"
$ErrorActionPreference = "Continue"

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 定义日志记录函数
function Log-Message {
    param([string]$message)
    Write-Host $message
    Add-Content -Path $logFilePath -Value $message
}

# 定义域名提取函数
function Extract-Domain {
    param([string]$line)
    if ($line -match '^\|\|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\^$' -or
        $line -match '^(0\.0\.0\.0|127\.0\.0\.1) ([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$' -or
        $line -match '^address=/([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$') {
        return $Matches[1]
    }
    return $null
}

# 使用并行处理下载并处理每个URL的内容
$urlList | ForEach-Object -Parallel {
    param($url, $uniqueRules)
    Log-Message "正在处理: $url"
    try {
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        $lines = $content.Content -split "`n"

        foreach ($line in $lines) {
            $domain = Extract-Domain $line
            if ($domain -and $domain -match '^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$') {
                $uniqueRules.Add($domain) | Out-Null
            }
        }
    }
    catch {
        Log-Message "处理 $url 时出错: $_"
    }
} -ArgumentList $_, $uniqueRules

# 创建新的HashSet来存储有效的规则
$validRules = $uniqueRules | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }

# 统计生成的规则条目数量
$ruleCount = $validRules.Count

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
$($validRules -join "`n")
"@

# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
$yamlContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Log-Message "生成的有效规则总数: $ruleCount"

Pause
