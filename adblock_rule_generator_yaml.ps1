# AdBlock Rule For Clash
# 这个脚本用于生成广告拦截规则，并将其保存为YAML格式

# 定义广告过滤器URL列表
# 这些URL包含了各种广告拦截规则的源
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
    "https://raw.githubusercontent.com/Lynricsy/HyperADRules/master/dns.txt",
    "https://raw.githubusercontent.com/guandasheng/adguardhome/main/rule/all.txt"
)

# 创建一个HashSet来存储唯一的规则
# 使用HashSet可以自动去重，提高效率
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

# 第一步：遍历每个广告过滤器URL，下载并提取拦截域名规则
# 创建WebClient对象用于下载URL内容
$webClient = New-Object System.Net.WebClient
# 设置编码为UTF8，确保正确处理非ASCII字符
$webClient.Encoding = [System.Text.Encoding]::UTF8
# 添加User-Agent头，模拟浏览器请求，避免被某些服务器拒绝
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

foreach ($url in $urlList) {
    Write-Host "正在处理: $url"
    try {
        # 下载URL内容
        $content = $webClient.DownloadString($url)
        # 将内容按行分割
        $lines = $content -split "`n"

        foreach ($line in $lines) {
            # 使用正则表达式匹配拦截域名规则
            if ($line -match '^\|\|([a-zA-Z0-9.-]+)\^') {
                $domain = $Matches[1]
                # 将匹配的域名添加到HashSet中
                $uniqueRules.Add($domain) | Out-Null
            }
        }
    }
    catch {
        # 如果处理某个URL时出错，输出错误信息但继续处理其他URL
        Write-Host "处理 $url 时出错: $_"
    }
}

# 第二步：去除无效域名规则
# 创建新的HashSet来存储有效的规则
$validRules = [System.Collections.Generic.HashSet[string]]::new()
foreach ($rule in $uniqueRules) {
    # 使用正则表达式验证域名的有效性
    if ($rule -match '^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$') {
        $validRules.Add($rule) | Out-Null
    }
}

# 第三步：将有效规则格式化为payload列表的格式
# 对规则进行排序并添加DOMAIN,前缀
$formattedRules = $validRules | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }

# 第四步：生成YAML文件内容
# 创建YAML格式的字符串，包含所有格式化后的规则
$yamlContent = @"
payload:
$($formattedRules -join "`n")
"@

# 第五步：保存生成的YAML文件
# 定义输出文件路径
$outputPath = "$PSScriptRoot/adblock_reject.yaml"
# 将YAML内容写入文件，使用UTF8编码
$yamlContent | Out-File -FilePath $outputPath -Encoding utf8

# 第六步：统计生成的规则条目数量
$ruleCount = $validRules.Count
# 输出生成的有效规则总数
Write-Host "生成的有效规则总数: $ruleCount"

# 确保脚本执行完后不自动退出
Pause
