# 关于AdBlock_Rule_For_Clash
一、从多个广告过滤器中提取拦截域名条目，删除重复项，并将它们转换为兼容Clash的payload列表格式。该列表可以用作Clash的rule-providers，以路由和阻止广告域名， powershell脚本每20分钟执行一次


二、理论上任何符合广告过滤器过滤语法的列表都可加入powershell脚本，请自行酌情添加过滤器订阅URL至脚本


三、本项目引用多个广告过滤器，从这些广告过滤器中提取了被拦截条目的域名，剔除了非拦截项，去重并格式化为适用于clash的yaml格式，最后生成yaml文件，可被引用用于clash配置文件中进行广告域名匹配拦截。


四、关于本项目使用方式：

  使用方式一：下载release中的adblock_reject_change.txt文件，里面的内容可直接粘贴到clash的yanl配置中的rules字段下



  使用方式二：将下面两个yaml配置文件中rule-providers字段和rules字段内容添加到你的yaml配置文件中，需要特别注意yaml文件的缩进和对齐。



        rule-providers:
          adblock:
            type: http
            behavior: domain
            format: yaml
            url: https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject.yaml
            path: ./ruleset/adblock_reject.yaml
            interval: 120
                    
                    
        rules:
          - RULE-SET,adblock,REJECT







五、本项目引用的广告过滤规则如下：

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



六、特别感谢以下各位大佬辛苦付出

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
