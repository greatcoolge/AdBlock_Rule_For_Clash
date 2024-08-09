# Title: AdBlock_Rule_For_Clash
# Description: 适用于Clash的域名拦截rule-providers，每20分钟更新一次，确保即时同步上游减少误杀
# Homepage: https://github.com/REIJI007/AdBlock_Rule_For_Clash

# 定义广告过滤器URL列表
$urlList = @(
    "https://anti-ad.net/adguard.txt",
    "https://anti-ad.net/easylist.txt",
    "https://easylist-downloads.adblockplus.org/easylist.txt",
    "https://easylist-downloads.adblockplus.org/easylistchina.txt",
    "https://easylist-downloads.adblockplus.org/easyprivacy.txt",
    "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt",
    "https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt",
    "https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_plus.txt",
    "https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_privacy.txt",
    "https://raw.githubusercontent.com/Cats-Team/AdRules/main/adblock_plus.txt",
    "https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt",
    "https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt",
    "https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockfilters.txt",
    "https://raw.githubusercontent.com/8680/GOODBYEADS/master/rules.txt",
    "https://raw.githubusercontent.com/8680/GOODBYEADS/master/dns.txt",
    "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt",
    "https://raw.githubusercontent.com/Bibaiji/ad-rules/main/rule/ad-rules.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-mobile.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_10_Useful/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt",
    "https://raw.githubusercontent.com/Lynricsy/HyperADRules/master/rules.txt",
    "https://raw.githubusercontent.com/Lynricsy/HyperADRules/master/dns.txt"
)

# 日志文件路径
$logFilePath = "$PSScriptRoot/adblock_log.txt"

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 定义下载和处理每个URL的函数
function Process-Url {
    param($url)
    Write-Host "正在处理: $url"
    Add-Content -Path $logFilePath -Value "正在处理: $url"

    $webClient = New-Object System.Net.WebClient
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

    try {
        $content = $webClient.DownloadString($url)
        $lines = $content -split "`n"

        foreach ($line in $lines) {
            # 支持多种广告规则格式的匹配，只提取完整域名
            if ($line -match '^\|\|([a-zA-Z0-9.-]+)\^' -or $line -match '^(0\.0\.0\.0|127\.0\.0\.1) ([a-zA-Z0-9.-]+)' -or $line -match '^address=/([a-zA-Z0-9.-]+)/') {
                $domain = $Matches[1]
                # 验证提取的内容是否为完整的域名
                if ($domain -match '^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$') {
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

# 使用并行处理URL列表
$urlList | ForEach-Object -Parallel {
    Process-Url -url $_
} -ThrottleLimit 10 # ThrottleLimit可以控制同时运行的并行作业数量

# 将有效规则格式化为带有“- DOMAIN,”前缀的格式
$formattedRules = $uniqueRules | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }

# 生成TXT文件内容
$ruleCount = $uniqueRules.Count
$txtContent = @"
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

# 保存生成的TXT文件
$outputPath = "$PSScriptRoot/adblock_reject.txt"
$txtContent | Out-File -FilePath $outputPath -Encoding utf8

# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"
Add-Content -Path $logFilePath -Value "生成的有效规则总数: $ruleCount"

Pause
