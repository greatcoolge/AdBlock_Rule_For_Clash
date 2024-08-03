# 关于AdBlock_Rule_For_Clash
##**一、从多个广告过滤器中提取拦截域名条目，删除重复项，并将它们转换为兼容Clash的payload列表格式，其中列表的每一项都写成了符合clash的Matcher Ruleset格式数组，一行仅一条规则。该列表可以用作Clash的rule-providers，以阻止广告域名， powershell脚本每20分钟执行生成新adblock_reject.txt和adblock_reject.yaml并发布在release中.四个文件的下载地址分别如下，其中adblock_reject.yaml和adblock_reject.txt是Matcher Ruleset格式数组构成的payload列表，adblock_reject_change.yaml和adblock_reject_change.txt则是纯粹的Matcher Ruleset数组**

*1、adblock_reject.yaml*

*https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject.yaml*

*https://cdn.jsdelivr.net/gh/REIJI007/AdBlock_Rule_For_Clash@main/adblock_reject.yaml*


*2、adblock_reject.txt*

*https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject.txt*

*https://cdn.jsdelivr.net/gh/REIJI007/AdBlock_Rule_For_Clash@main/adblock_reject.txt*


*3、adblock_reject_change.yaml*

*https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject_change.yaml*

*https://cdn.jsdelivr.net/gh/REIJI007/AdBlock_Rule_For_Clash@main/adblock_reject_change.yaml*


*4、adblock_reject_change.txt*

*https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject_change.txt*

*https://cdn.jsdelivr.net/gh/REIJI007/AdBlock_Rule_For_Clash@main/adblock_reject_change.txt*


##**二、理论上任何代理拦截域名且符合广告过滤器过滤语法的列表订阅URL都可加入powershell脚本处理，请自行酌情添加过滤器订阅URL至adblock_rule_generator.ps1脚本中进行处理，你可将该脚本代码复制到本地文本编辑器制作成.ps1后缀的文件运行在powershell上，注意修改生成的yaml文件路径，最后在clash的yaml配置中实现调用本地yaml文件作为规则集（RULE-SET)，clash配置字段写成类似于如下例子， 【path：生成本地yaml规则集文件路径】**
*简而言之就是可以让你DIY出希望得到的yaml格式拦截域名列表，缺点是此做法只能本地定制使用，当然你也可以像我一样部署到GitHub上面，仁者见仁*


        rule-providers:
          adblock:
            type: http
            behavior: domain
            format: yaml
            path: C:\Users\YourUsername\Documents\file.txt
        
        rules:
          - RULE-SET,adblock,REJECT

             





##**三、本仓库引用多个广告过滤器，从这些广告过滤器中提取了被拦截条目的域名，剔除了非拦截项并去重，最后做成payload列表，虽无法做到全面保护但能减少广告带来的困扰，请自行斟酌考虑使用。本仓库采取域名完全匹配策略，即匹配到于拦截列表上的域名完全一致时触发拦截，除此之外的情况给予放行**


##**四、关于本仓库使用方式：**

  *使用方式一：下载releases中的adblock_reject_change.txt文件，里面的内容可直接粘贴到clash的yaml配置中的rules字段下作为拦截规则（需要手动下载更新），adblock_reject_change.yaml则可以直接保存作为本地rule-providers，压缩包的两个powershell脚本分别用来生成adblock_reject.txt和adblock_reject.yaml,使用脚本前应当先将脚本内的文件生成存放路径更改为你电脑的路径*



  *使用方式二：将下面两个yaml配置文件中rule-providers字段和rules字段内容添加到你的yaml配置文件充当远程规则集，需要特别注意yaml文件的缩进和对齐（同步本仓库的云端部署配置)*



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




##**五、关于本仓库的使用效果为什么没有普通广告过滤器效果好的疑问解答：**
<br>
*因为普通的广告过滤器包含域名过滤（拦截广告域名）、路径过滤（例如拦截URL路径中包含/ads/的所有请求）、正则表达式过滤（例如拦截所有包含ads.js或ad.js的URL）、类型过滤（例如只拦截图片资源）、隐藏元素等等多因素作用下使得在广告拦截测试网站中可以取得高分。但碍于clash内核的路由模式（可参考相关内核文档），本仓库仅提取了被拦截域名进行域名过滤，换言之，本仓库就是一个“删减版”的广告过滤器（仅保留了域名过滤功能），所以最终效果只有六七十分体现在广告拦截测试网站上，例如https://adblock-tester.com/*




##**六、本仓库引用的广告过滤规则如下，是否误杀域名完全取决于这些处于上游的广告过滤器的域名拦截行为，若不满意的话可按照第二条进行DIY本地定制化，也可以像我一样DIY好了就部署到github上面**

1、Anti-ad for adguard<br>
https://anti-ad.net/adguard.txt


2、Anti-ad-Easylist<br>
https://anti-ad.net/easylist.txt
    
    
3、EasyList<br>
https://easylist-downloads.adblockplus.org/easylist.txt


4、EasyList  china<br>
https://easylist-downloads.adblockplus.org/easylistchina.txt


5、EasyList Privacy<br>
https://easylist-downloads.adblockplus.org/easyprivacy.txt
    
    
6、AdGuardSDNSFilter<br>
https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt
    
    
7、CJX's Annoyance List<br>
https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt
    
    
8、uniartisan's Adblock List Plus<br>
https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_plus.txt


9、uniartisan's Privacy List<br>
https://raw.githubusercontent.com/uniartisan/adblock_list/master/adblock_privacy.txt
    
    
10、AdRules AdBlock List Plus<br>
https://raw.githubusercontent.com/Cats-Team/AdRules/main/adblock_plus.txt


11、AdRules DNS List<br>
https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt
    
    
12、AdBlock DNS<br>
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt


13、AdBlock Filter<br>
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockfilters.txt
    
    
14、GOODBYEADS<br>
https://raw.githubusercontent.com/8680/GOODBYEADS/master/rules.txt


15、GOODBYEADS-DNS<br>
https://raw.githubusercontent.com/8680/GOODBYEADS/master/dns.txt
    
    
16、AWAvenue-Ads-Rule<br>
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt
    
    
17、Bibaiji's ad-rules<br>
https://raw.githubusercontent.com/Bibaiji/ad-rules/main/rule/ad-rules.txt
    
    
18、uBlock filters<br>
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt


19、uBlock privacy<br>
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt


20、uBlock mobile filter<br>
https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-mobile.txt


21、Adgurd Base filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt


22、Adgurd Tracking Protection filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt


23、Adgurd URL Tracking filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt


24、Adgurd Social media filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt


25、Adgurd Annoyances filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt


26、Filter unblocking search ads and self-promotions<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_10_Useful/filter.txt


27、Adgurd Chinese filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt


28、Adgurd Japanese filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt


29、Adgurd Mobile ads filter<br>
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt


30、Adgurd DNS filter<br>
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
