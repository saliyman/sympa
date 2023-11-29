# -*- indent-tabs-mode: nil; -*-
# vim:ft=perl:et:sw=4

# Sympa - SYsteme de Multi-Postage Automatique

# NOTE: This file is auto-generated.  Don't edit it manually.
# Instead, modifications should be made on support/make_crawlers.pl file.

package Sympa::WWW::Crawlers;

use strict;
use warnings;

use constant crawler => qr{
  (
    Googlebot\/
  | Googlebot-Mobile
  | Googlebot-Image
  | Googlebot-News
  | Googlebot-Video
  | AdsBot-Google([^-]|$)
  | AdsBot-Google-Mobile
  | Feedfetcher-Google
  | Mediapartners-Google
  | Mediapartners[ ]\(Googlebot\)
  | APIs-Google
  | Google-InspectionTool
  | Storebot-Google
  | GoogleOther
  | bingbot
  | Slurp
  | [wW]get
  | LinkedInBot
  | Python-urllib
  | python-requests
  | aiohttp
  | httpx
  | libwww-perl
  | httpunit
  | nutch
  | Go-http-client
  | phpcrawl
  | msnbot
  | jyxobot
  | FAST-WebCrawler
  | FAST[ ]Enterprise[ ]Crawler
  | BIGLOTRON
  | Teoma
  | convera
  | seekbot
  | Gigabot
  | Gigablast
  | exabot
  | ia_archiver
  | GingerCrawler
  | webmon[ ]
  | HTTrack
  | grub\.org
  | UsineNouvelleCrawler
  | antibot
  | netresearchserver
  | speedy
  | fluffy
  | findlink
  | msrbot
  | panscient
  | yacybot
  | AISearchBot
  | ips-agent
  | tagoobot
  | MJ12bot
  | woriobot
  | yanga
  | buzzbot
  | mlbot
  | yandex\.com\/bots
  | purebot
  | Linguee[ ]Bot
  | CyberPatrol
  | voilabot
  | Baiduspider
  | citeseerxbot
  | spbot
  | twengabot
  | postrank
  | Turnitin
  | scribdbot
  | page2rss
  | sitebot
  | linkdex
  | Adidxbot
  | ezooms
  | dotbot
  | Mail\.RU_Bot
  | discobot
  | heritrix
  | findthatfile
  | europarchive\.org
  | NerdByNature\.Bot
  | sistrix[ ]crawler
  | Ahrefs(Bot|SiteAudit)
  | fuelbot
  | CrunchBot
  | IndeedBot
  | mappydata
  | woobot
  | ZoominfoBot
  | PrivacyAwareBot
  | Multiviewbot
  | SWIMGBot
  | Grobbot
  | eright
  | Apercite
  | semanticbot
  | Aboundex
  | domaincrawler
  | wbsearchbot
  | summify
  | CCBot
  | edisterbot
  | SeznamBot
  | ec2linkfinder
  | gslfbot
  | aiHitBot
  | intelium_bot
  | facebookexternalhit
  | Yeti
  | RetrevoPageAnalyzer
  | lb-spider
  | Sogou
  | lssbot
  | careerbot
  | wotbox
  | wocbot
  | ichiro
  | DuckDuckBot
  | lssrocketcrawler
  | drupact
  | webcompanycrawler
  | acoonbot
  | openindexspider
  | gnam[ ]gnam[ ]spider
  | web-archive-net\.com\.bot
  | backlinkcrawler
  | coccoc
  | integromedb
  | content[ ]crawler[ ]spider
  | toplistbot
  | it2media-domain-crawler
  | ip-web-crawler\.com
  | siteexplorer\.info
  | elisabot
  | proximic
  | changedetection
  | arabot
  | WeSEE:Search
  | niki-bot
  | CrystalSemanticsBot
  | rogerbot
  | 360Spider
  | psbot
  | InterfaxScanBot
  | CC[ ]Metadata[ ]Scaper
  | g00g1e\.net
  | GrapeshotCrawler
  | urlappendbot
  | brainobot
  | fr-crawler
  | binlar
  | SimpleCrawler
  | Twitterbot
  | cXensebot
  | smtbot
  | bnf\.fr_bot
  | A6-Indexer
  | ADmantX
  | Facebot
  | OrangeBot\/
  | memorybot
  | AdvBot
  | MegaIndex
  | SemanticScholarBot
  | ltx71
  | nerdybot
  | xovibot
  | BUbiNG
  | Qwantify
  | archive\.org_bot
  | Applebot
  | TweetmemeBot
  | crawler4j
  | findxbot
  | S[eE][mM]rushBot
  | yoozBot
  | lipperhey
  | Y!J
  | Domain[ ]Re-Animator[ ]Bot
  | AddThis
  | Screaming[ ]Frog[ ]SEO[ ]Spider
  | MetaURI
  | Scrapy
  | Livelap[bB]ot
  | OpenHoseBot
  | CapsuleChecker
  | collection\@infegy\.com
  | IstellaBot
  | DeuSu\/
  | betaBot
  | Cliqzbot\/
  | MojeekBot\/
  | netEstate[ ]NE[ ]Crawler
  | SafeSearch[ ]microdata[ ]crawler
  | Gluten[ ]Free[ ]Crawler\/
  | Sonic
  | Sysomos
  | Trove
  | deadlinkchecker
  | Slack-ImgProxy
  | Embedly
  | RankActiveLinkBot
  | iskanie
  | SafeDNSBot
  | SkypeUriPreview
  | Veoozbot
  | Slackbot
  | redditbot
  | datagnionbot
  | Google-Adwords-Instant
  | adbeat_bot
  | WhatsApp
  | contxbot
  | pinterest\.com\.bot
  | electricmonk
  | GarlikCrawler
  | BingPreview\/
  | vebidoobot
  | FemtosearchBot
  | Yahoo[ ]Link[ ]Preview
  | MetaJobBot
  | DomainStatsBot
  | mindUpBot
  | Daum\/
  | Jugendschutzprogramm-Crawler
  | Xenu[ ]Link[ ]Sleuth
  | Pcore-HTTP
  | moatbot
  | KosmioBot
  | [pP]ingdom
  | AppInsights
  | PhantomJS
  | Gowikibot
  | PiplBot
  | Discordbot
  | TelegramBot
  | Jetslide
  | newsharecounts
  | James[ ]BOT
  | Bark[rR]owler
  | TinEye
  | SocialRankIOBot
  | trendictionbot
  | Ocarinabot
  | epicbot
  | Primalbot
  | DuckDuckGo-Favicons-Bot
  | GnowitNewsbot
  | Leikibot
  | LinkArchiver
  | YaK\/
  | PaperLiBot
  | Digg[ ]Deeper
  | dcrawl
  | Snacktory
  | AndersPinkBot
  | Fyrebot
  | EveryoneSocialBot
  | Mediatoolkitbot
  | Luminator-robots
  | ExtLinksBot
  | SurveyBot
  | NING\/
  | okhttp
  | Nuzzel
  | omgili
  | PocketParser
  | YisouSpider
  | um-LN
  | ToutiaoSpider
  | MuckRack
  | Jamie's[ ]Spider
  | AHC\/
  | NetcraftSurveyAgent
  | Laserlikebot
  | ^Apache-HttpClient
  | AppEngine-Google
  | Jetty
  | Upflow
  | Thinklab
  | Traackr\.com
  | Twurly
  | Mastodon
  | http_get
  | DnyzBot
  | botify
  | 007ac9[ ]Crawler
  | BehloolBot
  | BrandVerity
  | check_http
  | BDCbot
  | ZumBot
  | EZID
  | ICC-Crawler
  | ArchiveBot
  | ^LCC[ ]
  | filterdb\.iss\.net\/crawler
  | BLP_bbot
  | BomboraBot
  | Buck\/
  | Companybook-Crawler
  | Genieo
  | magpie-crawler
  | MeltwaterNews
  | Moreover
  | newspaper\/
  | ScoutJet
  | (^|[ ])sentry\/
  | StorygizeBot
  | UptimeRobot
  | OutclicksBot
  | seoscanners
  | Hatena
  | Google[ ]Web[ ]Preview
  | MauiBot
  | AlphaBot
  | SBL-BOT
  | IAS[ ]crawler
  | adscanner
  | Netvibes
  | acapbot
  | Baidu-YunGuanCe
  | bitlybot
  | blogmuraBot
  | Bot\.AraTurka\.com
  | bot-pge\.chlooe\.com
  | BoxcarBot
  | BTWebClient
  | ContextAd[ ]Bot
  | Digincore[ ]bot
  | Disqus
  | Feedly
  | Fetch\/
  | Fever
  | Flamingo_SearchEngine
  | FlipboardProxy
  | g2reader-bot
  | G2[ ]Web[ ]Services
  | imrbot
  | K7MLWCBot
  | Kemvibot
  | Landau-Media-Spider
  | linkapediabot
  | vkShare
  | Siteimprove\.com
  | BLEXBot\/
  | DareBoost
  | ZuperlistBot\/
  | Miniflux\/
  | Feedspot
  | Diffbot\/
  | SEOkicks
  | tracemyfile
  | Nimbostratus-Bot
  | zgrab
  | PR-CY\.RU
  | AdsTxtCrawler
  | Datafeedwatch
  | Zabbix
  | TangibleeBot
  | google-xrawler
  | axios
  | Amazon[ ]CloudFront
  | Pulsepoint
  | CloudFlare-AlwaysOnline
  | Google-Structured-Data-Testing-Tool
  | WordupInfoSearch
  | WebDataStats
  | HttpUrlConnection
  | Seekport[ ]Crawler
  | ZoomBot
  | VelenPublicWebCrawler
  | MoodleBot
  | jpg-newsbot
  | outbrain
  | W3C_Validator
  | Validator\.nu
  | W3C-checklink
  | W3C-mobileOK
  | W3C_I18n-Checker
  | FeedValidator
  | W3C_CSS_Validator
  | W3C_Unicorn
  | Google-PhysicalWeb
  | Blackboard
  | ICBot\/
  | BazQux
  | Twingly
  | Rivva
  | Experibot
  | awesomecrawler
  | Dataprovider\.com
  | GroupHigh\/
  | theoldreader\.com
  | AnyEvent
  | Uptimebot\.org
  | Nmap[ ]Scripting[ ]Engine
  | 2ip\.ru
  | Clickagy
  | Caliperbot
  | MBCrawler
  | online-webceo-bot
  | B2B[ ]Bot
  | AddSearchBot
  | Google[ ]Favicon
  | HubSpot
  | Chrome-Lighthouse
  | HeadlessChrome
  | CheckMarkNetwork\/
  | www\.uptime\.com
  | Streamline3Bot\/
  | serpstatbot\/
  | MixnodeCache\/
  | ^curl
  | SimpleScraper
  | RSSingBot
  | Jooblebot
  | fedoraplanet
  | Friendica
  | NextCloud
  | Tiny[ ]Tiny[ ]RSS
  | RegionStuttgartBot
  | Bytespider
  | Datanyze
  | Google-Site-Verification
  | TrendsmapResolver
  | tweetedtimes
  | NTENTbot
  | Gwene
  | SimplePie
  | SearchAtlas
  | Superfeedr
  | feedbot
  | UT-Dorkbot
  | Amazonbot
  | SerendeputyBot
  | Eyeotabot
  | officestorebot
  | Neticle[ ]Crawler
  | SurdotlyBot
  | LinkisBot
  | AwarioSmartBot
  | AwarioRssBot
  | RyteBot
  | FreeWebMonitoring[ ]SiteChecker
  | AspiegelBot
  | NAVER[ ]Blog[ ]Rssbot
  | zenback[ ]bot
  | SentiBot
  | Domains[ ]Project\/
  | Pandalytics
  | VKRobot
  | bidswitchbot
  | tigerbot
  | NIXStatsbot
  | Atom[ ]Feed[ ]Robot
  | [Cc]urebot
  | PagePeeker\/
  | Vigil\/
  | rssbot\/
  | startmebot\/
  | JobboerseBot
  | seewithkids
  | NINJA[ ]bot
  | Cutbot
  | BublupBot
  | BrandONbot
  | RidderBot
  | Taboolabot
  | Dubbotbot
  | FindITAnswersbot
  | infoobot
  | Refindbot
  | BlogTraffic\/\d\.\d+[ ]Feed-Fetcher
  | SeobilityBot
  | Cincraw
  | Dragonbot
  | VoluumDSP-content-bot
  | FreshRSS
  | BitBot
  | ^PHP-Curl-Class
  | Google-Certificates-Bridge
  | centurybot
  | Viber
  | e\.ventures[ ]Investment[ ]Crawler
  | evc-batch
  | PetalBot
  | virustotal
  | (^|[ ])PTST\/
  | minicrawler
  | Cookiebot
  | trovitBot
  | seostar\.co
  | IonCrawl
  | Uptime-Kuma
  | SeekportBot
  | FreshpingBot
  | Feedbin
  | CriteoBot
  | Snap[ ]URL[ ]Preview[ ]Service
  | Better[ ]Uptime[ ]Bot
  | RuxitSynthetic
  | Google-Read-Aloud
  | Valve\/Steam
  | OdklBot\/
  | GPTBot
  | YandexRenderResourcesBot\/
  | LightspeedSystemsCrawler
  | ev-crawler\/
  | BitSightBot\/
  | woorankreview\/
  | Google-Safety
  | AwarioBot
  | DataForSeoBot
  | Linespider
  | WellKnownBot
  | A[ ]Patent[ ]Crawler
  | StractBot
  | search\.marginalia\.nu
  | YouBot
  | Nicecrawler
  | Neevabot
  | BrightEdge[ ]Crawler
  | SiteCheckerBotCrawler
  | TombaPublicWebCrawler
  | CrawlyProjectCrawler
  | KomodiaBot
  | KStandBot
  | CISPA[ ]Webcrawler
  | MTRobot
  | hyscore\.io
  | AlexandriaOrgBot
  | 2ip[ ]bot
  | Yellowbrandprotectionbot
  | SEOlizer
  | vuhuvBot
  | INETDEX-BOT
  | Synapse
  | t3versionsBot
  | deepnoc
  | Cocolyzebot
  | hypestat
  | ReverseEngineeringBot
  | sempi\.tech
  | Iframely
  | MetaInspector
  | node-fetch
  | lkxscan
  | python-opengraph
  | OpenGraphCheck
  | developers\.google\.com\/\+\/web\/snippet
  | SenutoBot
  | MaCoCu
  | NewsBlur
  | inoreader
  | NetSystemsResearch
  | PageThing
  | WordPress\/
  | PhxBot
  | ImagesiftBot
  )
}x;

1;

__END__
=encoding utf-8

=head1 NAME

Sympa::WWW::Crawlers - Regular expression for User-Agent of web crawlers

=head1 DESCRIPTION

This module keeps definition of regular expressions used by Sympa software.

The regular expression is generated from the data provided by the
project below.

=head1 SEE ALSO

=over

=item *

Syntactic patterns of HTTP user-agents used by bots / robots / crawlers /
scrapers / spiders

L<https://github.com/monperrus/crawler-user-agents>

=back


=head1 HISTORY

Crawler detection feature of WWSympa was introduced on Sympa 5.4a.4
which derives information provided by L<http://www.useragentstring.com>.

On Sympa 6.2.73b, it was replaced with regular expression matching
using information provided by crawler-user-agents project above.

=cut
