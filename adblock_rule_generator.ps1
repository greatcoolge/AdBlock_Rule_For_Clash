# 设置窗口标题并清屏
$host.UI.RawUI.WindowTitle = "AdBlock Rule Generator"  # 设置命令行窗口标题为“AdBlock Rule Generator”
Clear-Host  # 清空命令行窗口内容
Write-Host "AdBlock Rule Generator" -ForegroundColor Cyan  # 在命令行窗口显示标题“AdBlock Rule Generator”，并设置字体颜色为青色

# 定义广告过滤器URL列表
$urlList = @(  # 定义一个数组，包含多个广告过滤器的URL
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
    "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt"
)

# 创建一个HashSet来存储唯一的规则
$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()  # 创建一个HashSet来存储唯一的广告过滤规则

# 第一步：遍历每个广告过滤器URL，下载并提取拦截域名规则
$webClient = New-Object System.Net.WebClient  # 创建一个WebClient对象，用于下载URL内容
$webClient.Encoding = [System.Text.Encoding]::UTF8  # 设置WebClient对象的编码为UTF8
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")  # 添加User-Agent头，模拟浏览器请求

foreach ($url in $urlList) {  # 遍历每个广告过滤器URL
    Write-Host "正在处理: $url" -ForegroundColor Yellow  # 输出当前处理的URL，并设置字体颜色为黄色
    try {
        $content = $webClient.DownloadString($url)  # 下载URL内容
        $lines = $content -split "`n"  # 将下载的内容按行分割

        foreach ($line in $lines) {  # 遍历每行内容
            if ($line -match '^\|\|([a-zA-Z0-9.-]+)\^') {  # 匹配拦截域名规则
                $domain = $Matches[1]  # 提取域名
                $uniqueRules.Add($domain) | Out-Null  # 将域名添加到HashSet中，确保唯一性
            }
        }
    }
    catch {
        Write-Host "处理 $url 时出错: $_" -ForegroundColor Red  # 如果下载或处理URL内容时出错，输出错误信息，并设置字体颜色为红色
    }
}

# 第二步：去除无效域名规则
$validRules = [System.Collections.Generic.HashSet[string]]::new()  # 创建一个HashSet来存储有效的域名规则
foreach ($rule in $uniqueRules) {  # 遍历所有唯一的域名规则
    if ($rule -match '^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$') {  # 验证域名规则的有效性
        $validRules.Add($rule) | Out-Null  # 将有效的域名规则添加到HashSet中
    }
}

# 第三步：将有效规则格式化为payload列表的格式
$formattedRules = $validRules | Sort-Object | ForEach-Object { "  - DOMAIN,$_" }  # 对有效的域名规则进行排序并格式化为payload列表的格式

# 第四步：生成YAML文件内容
$yamlContent = @"
payload:
$($formattedRules -join "`n")
"@  # 生成YAML文件内容

# 第五步：保存生成的YAML文件
$outputPath = "$PSScriptRoot\adblock_reject.yaml"  # 设置YAML文件的输出路径为脚本所在目录
$yamlContent | Out-File -FilePath $outputPath -Encoding utf8  # 将YAML内容保存到文件中，使用UTF8编码

# 第六步：统计生成的规则条目数量
$ruleCount = $validRules.Count  # 统计有效规则的数量
Write-Host "生成的有效规则总数: $ruleCount" -ForegroundColor Green  # 输出有效规则的总数，并设置字体颜色为绿色

# 第七步：等待用户按任意键退出
Write-Host "按任意键退出..."  # 提示用户按任意键退出
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")  # 等待用户按任意键
