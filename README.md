# 关于AdBlock_Rule_For_Clash
##**一、从多个广告过滤器中提取拦截域名条目，删除重复项，并将它们转换为兼容Clash的payload列表格式。该列表可以用作Clash的rule-providers，以路由和阻止广告域名， powershell脚本每20分钟执行一次**


##**二、理论上任何符合广告过滤器过滤语法的列表订阅URL都可加入powershell脚本处理，请自行酌情添加过滤器订阅URL至adblock_rule_generator.ps1脚本中进行处理，你可将该脚本代码复制到本地文本编辑器制作成.ps1后缀的文件运行在powershell上，注意修改生成的yaml文件路径，最后在clash的yaml配置中实现调用本地yaml文件作为规则集，clash配置字段写成类似于如下例子， 【path：生成本地yaml规则集文件路径】**


       rule-providers:
          adblock:
            type: http
            behavior: domain
            format: yaml
            path: C:\Users\YourUsername\Documents\file.txt

       rules:
          - RULE-SET,adblock,REJECT

             





##**三、本仓库引用多个广告过滤器，从这些广告过滤器中提取了被拦截条目的域名，剔除了非拦截项并去重，最后做成payload列表，虽无法做到全面保护但能减少广告带来的困扰，请自行斟酌考虑使用**


##**四、关于本仓库使用方式：**

  *使用方式一：下载releases中的adblock_reject_change.txt文件，里面的内容可直接粘贴到clash的yaml配置中的rules字段下作为拦截规则*



  *使用方式二：将下面两个yaml配置文件中rule-providers字段和rules字段内容添加到你的yaml配置文件充当远程规则集中，需要特别注意yaml文件的缩进和对齐。*



        rule-providers:
          adblock:
            type: http
            behavior: domain
            format: yaml
            url: https://cdn.jsdelivr.net/gh/REIJI007/AdBlock_Rule_For_Clash@main/adblock_reject.yaml
            path: ./ruleset/adblock_reject.yaml
            interval: 120
                    
                    
        rules:
          - RULE-SET,adblock,REJECT







##**五、本仓库引用的广告过滤规则如下：**

1、Anti-ad for adguard
https://anti-ad.net/adguard.txt


2、Anti-ad-Easylist
https://anti-ad.net/easylist.txt
    
    
3、EasyList 
https://easylist-downloads.adblockplus.org/easylist.txt


4、EasyList  china
https://easylist-downloads.adblockplus.org/easylistchina.txt


5、EasyList Privacy
https://easylist-downloads.adblockplus.org/easyprivacy.txt
    
    
6、AdGuardSDNSFilter
https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt
    
    
7、CJX's Annoyance List
https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt
    
    
8、uniartisan's Adblock List Plus
https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_plus.txt


9、uniartisan's Privacy List
https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_privacy.txt
    
    
10、AdRules AdBlock List Plus
https://raw.githubusercontent.com/Cats-Team/AdRules/main/adblock_plus.txt


11、AdRules DNS List
https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt
    
    
12、AdBlock DNS
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt


13、AdBlock Filter
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockfilters.txt
    
    
14、GOODBYEADS
https://raw.githubusercontent.com/8680/GOODBYEADS/master/rules.txt


15、GOODBYEADS-Dns
https://raw.githubusercontent.com/8680/GOODBYEADS/master/dns.txt
    
    
16、AWAvenue-Ads-Rule
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt
    
    
17、Bibaiji's ad-rules
https://raw.githubusercontent.com/Bibaiji/ad-rules/main/rule/ad-rules.txt
    
    
18、uBlock filters
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt


19、uBlock privacy
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt


20、uBlock mobile filter
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-mobile.txt


21、Adgurd Base filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt


22、Adgurd Tracking Protection filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt


23、Adgurd URL Tracking filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt


24、Adgurd Social media filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt


25、Adgurd Annoyances filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt


26、Filter unblocking search ads and self-promotions
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_10_Useful/filter.txt


27、Adgurd Chinese filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt


28、Adgurd Japanese filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt


29、Adgurd Mobile ads filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt


30、Adgurd DNS filter
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt





##**六、特别感谢以下各位大佬辛苦付出**

1、anti-AD (https://github.com/privacy-protection-tools/anti-AD)

2、easylist (https://github.com/easylist/easylist)

3、cjxlist (https://github.com/cjx82630/cjxlist)

4、uniartisan (https://github.com/uniartisan/adblock_list)

5、Cats-Team (https://github.com/Cats-Team/AdRules)

6、217heidai (https://github.com/217heidai/adblockfilters)

7、GOODBYEADS (https://github.com/8680/GOODBYEADS)

8、AWAvenue-Ads-Rule (https://github.com/TG-Twilight/AWAvenue-Ads-Rule)

9、Bibaiji (https://github.com/Bibaiji/ad-rules/)

10、uBlockOrigin (https://github.com/uBlockOrigin/uAssets)

11、ADguardTeam (https://github.com/AdguardTeam/AdGuardFilters)
