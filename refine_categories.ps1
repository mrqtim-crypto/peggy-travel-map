[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$inputPath = "c:\Users\ken03\Downloads\Takeout\地圖 (你的地點)\已儲存的地點.json"
$outputPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\places.json"
$dataJsPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\data.js"

$rawText = [System.IO.File]::ReadAllText($inputPath, [System.Text.Encoding]::UTF8)
$data = $rawText | ConvertFrom-Json
$features = $data.features

# 國外國碼對照表
$countryCodeMap = @{
    "JP" = "日本"; "KR" = "韓國"; "TH" = "泰國"; "VN" = "越南"; "IS" = "冰島";
    "TR" = "土耳其"; "MO" = "澳門"; "HK" = "香港"; "ID" = "印尼"; "MV" = "馬爾地夫";
    "SG" = "新加坡"; "MY" = "馬來西亞"; "CN" = "中國"; "US" = "美國"; "FR" = "法國";
    "IT" = "義大利"; "GB" = "英國"; "UK" = "英國"; "DE" = "德國"; "ES" = "西班牙";
    "AU" = "澳洲"; "CA" = "加拿大"; "CH" = "瑞士"; "NL" = "荷蘭"; "AT" = "奧地利";
    "NZ" = "紐西蘭"; "PH" = "菲律賓"
}

# 國外關鍵字
$intlKeywords = @(
    @{ Name = "泰國"; Keywords = @("泰國", "Thailand", "Bangkok", "曼谷", "Chiang Mai", "清邁", "Phuket", "普吉", "Pattaya", "芭達雅") },
    @{ Name = "日本"; Keywords = @("日本", "Japan", "Tokyo", "東京", "Osaka", "大阪", "Kyoto", "京都", "Fukuoka", "福岡", "Okinawa", "沖繩", "Hokkaido", "北海道", "Nagoya", "名古屋", "札幌", "那霸", "Naha", "熊本", "銀座", "新宿", "澀谷", "心齋橋") },
    @{ Name = "韓國"; Keywords = @("韓國", "Korea", "Seoul", "首爾", "Busan", "釜山", "Jeju", "濟州", "弘大", "明洞", "江南", "東大門", "海雲台") },
    @{ Name = "越南"; Keywords = @("越南", "Vietnam", "Hanoi", "河內", "Da Nang", "峴港", "Ho Chi Minh", "胡志明", "Hoi An", "會安", "富國島") },
    @{ Name = "冰島"; Keywords = @("冰島", "Iceland", "Reykjavik", "雷克雅維克") },
    @{ Name = "土耳其"; Keywords = @("土耳其", "Turkey", "Istanbul", "伊斯坦堡", "Cappadocia", "卡帕多奇亞") },
    @{ Name = "澳門"; Keywords = @("澳門", "Macau", "氹仔") },
    @{ Name = "香港"; Keywords = @("香港", "Hong Kong", "尖沙咀", "中環", "旺角") },
    @{ Name = "印尼"; Keywords = @("印尼", "Indonesia", "Bali", "峇里島") },
    @{ Name = "馬爾地夫"; Keywords = @("馬爾地夫", "Maldives") },
    @{ Name = "新加坡"; Keywords = @("新加坡", "Singapore") },
    @{ Name = "歐洲/其他海外"; Keywords = @("France", "法國", "Italy", "義大利", "Germany", "德國", "UK", "英國", "London", "倫敦", "Paris", "巴黎", "USA", "美國", "New York", "紐約", "Los Angeles") }
)

# 台灣縣市
$twCounties = @(
    @{ Name = "基隆市"; Short = "基隆"; Keywords = @("基隆", "Keelung", "暖暖", "七堵", "安樂區", "仁愛區") },
    @{ Name = "台北市"; Short = "台北"; Keywords = @("台北", "臺北", "Taipei", "中正區", "大同區", "中山區", "松山區", "大安區", "萬華區", "信義區", "士林區", "北投區", "內湖區", "南港區", "文山區") },
    @{ Name = "新北市"; Short = "新北"; Keywords = @("新北", "New Taipei", "板橋", "三重", "中和", "永和", "新莊", "新店", "樹林", "鶯歌", "三峽", "淡水", "汐止", "瑞芳", "土城", "蘆洲", "五股", "泰山", "林口", "深坑", "石碇", "坪林", "三芝", "石門", "八里", "平溪", "雙溪", "貢寮", "金山", "萬里", "烏來", "九份", "金瓜石") },
    @{ Name = "桃園市"; Short = "桃園"; Keywords = @("桃園", "Taoyuan", "中壢", "平鎮", "八德", "楊梅", "蘆竹", "大溪", "龍潭", "龜山", "大園", "觀音", "新屋", "復興") },
    @{ Name = "新竹縣市"; Short = "新竹"; Keywords = @("新竹", "Hsinchu", "竹北", "竹東", "新埔", "關西", "湖口", "新豐", "芎林", "橫山", "北埔", "寶山", "峨眉", "尖石", "五峰") },
    @{ Name = "苗栗縣"; Short = "苗栗"; Keywords = @("苗栗", "Miaoli", "頭份", "竹南", "後龍", "通霄", "苑裡", "造橋", "三灣", "南庄", "頭屋", "獅潭", "西湖", "公館", "銅鑼", "三義", "大湖", "泰安", "卓蘭") },
    @{ Name = "台中市"; Short = "台中"; Keywords = @("台中", "臺中", "Taichung", "西屯", "南屯", "北屯", "豐原", "大里", "太平", "清水", "沙鹿", "大甲", "東勢", "梧棲", "烏日", "神岡", "大雅", "后里", "霧峰", "潭子", "大肚", "外埔", "龍井", "石岡", "和平", "新社") },
    @{ Name = "彰化縣"; Short = "彰化"; Keywords = @("彰化", "Changhua", "員林", "和美", "鹿港", "溪湖", "二林", "田中", "北斗", "花壇", "芬園", "大村", "永靖", "伸港", "線西", "福興", "秀水", "埔心", "埔鹽", "大城", "芳苑", "二水", "埤頭", "溪州", "竹塘", "社頭", "田尾") },
    @{ Name = "南投縣"; Short = "南投"; Keywords = @("南投", "Nantou", "埔里", "草屯", "竹山", "集集", "名間", "鹿谷", "中寮", "魚池", "國姓", "水里", "清境", "日月潭") },
    @{ Name = "雲林縣"; Short = "雲林"; Keywords = @("雲林", "Yunlin", "斗六", "斗南", "虎尾", "西螺", "土庫", "北港", "古坑", "大埤", "莿桐", "林內", "二崙", "崙背", "麥寮", "東勢鄉", "褒忠", "台西", "元長", "四湖", "口湖", "水林") },
    @{ Name = "嘉義縣市"; Short = "嘉義"; Keywords = @("嘉義", "Chiayi", "太保", "朴子", "布袋", "大林", "民雄", "溪口", "新港", "六腳", "東石", "義竹", "鹿草", "水上", "中埔", "竹崎", "梅山", "番路", "大埔", "阿里山") },
    @{ Name = "台南市"; Short = "台南"; Keywords = @("台南", "臺南", "Tainan", "安平", "中西區", "東區", "南區", "北區", "安南", "永康", "歸仁", "新化", "左鎮", "玉井", "楠西", "南化", "仁德", "關廟", "龍崎", "官田", "麻豆", "佳里", "西港", "七股", "將軍", "學甲", "北門", "新營", "後壁", "白河", "東山", "六甲", "下營", "柳營", "鹽水", "善化", "大內", "山上", "新市", "安定") },
    @{ Name = "高雄市"; Short = "高雄"; Keywords = @("高雄", "Kaohsiung", "楠梓", "左營", "鼓山", "三民", "鹽埕", "前金", "新興", "苓雅", "前鎮", "旗津", "小港", "鳳山", "大寮", "鳥松", "林園", "仁武", "大樹", "大社", "岡山", "路竹", "阿蓮", "田寮", "燕巢", "橋頭", "梓官", "彌陀", "永安", "湖內", "旗山", "美濃", "六龜", "甲仙", "杉林", "內門", "茂林", "桃源", "那瑪夏") },
    @{ Name = "屏東縣"; Short = "屏東"; Keywords = @("屏東", "Pingtung", "潮州", "東港", "恆春", "萬丹", "長治", "麟洛", "九如", "里港", "鹽埔", "高樹", "萬巒", "內埔", "竹田", "新埤", "枋寮", "枋山", "春日", "獅子", "車城", "牡丹", "滿州", "墾丁", "小琉球", "琉球") },
    @{ Name = "宜蘭縣"; Short = "宜蘭"; Keywords = @("宜蘭", "Yilan", "羅東", "蘇澳", "頭城", "礁溪", "壯圍", "員山", "冬山", "五結", "三星", "大同鄉", "南澳") },
    @{ Name = "花蓮縣"; Short = "花蓮"; Keywords = @("花蓮", "Hualien", "鳳林", "玉里", "新城", "吉安", "壽豐", "光復", "豐濱", "瑞穗", "富里", "秀林", "萬榮", "卓溪") },
    @{ Name = "台東縣"; Short = "台東"; Keywords = @("台東", "臺東", "Taitung", "成功", "關山", "卑南", "大武", "太麻里", "東河", "長濱", "鹿野", "池上", "綠島", "蘭嶼", "延平", "海端", "達仁", "金峰") },
    @{ Name = "澎湖縣"; Short = "澎湖"; Keywords = @("澎湖", "Penghu", "馬公", "湖西", "白沙", "西嶼", "望安", "七美") },
    @{ Name = "金門縣"; Short = "金門"; Keywords = @("金門", "Kinmen", "金城", "金湖", "金沙", "金寧", "烈嶼") },
    @{ Name = "連江縣"; Short = "馬祖"; Keywords = @("馬祖", "Matsu", "連江", "南竿", "北竿", "莒光", "東引") }
)

# 依優先順序比對分類
$rules = @(
    @{ 
        Category = "住宿/飯店"
        Keywords = @("hotel", "飯店", "酒店", "民宿", "旅館", "inn", "resort", "hostel", "villa", "渡假村", "露營區", "露營地", "露營", "營地", "青年旅館", "會館", "商旅", "旅店", "b&b", "guesthouse", "stay", "lodge", "glamping") 
    },
    @{ 
        Category = "按摩/SPA/體驗"
        Keywords = @("massage", "spa", "按摩", "指壓", "油壓", "泰式按摩", "芳療", "水療", "美甲", "美睫", "採耳", "體驗", "工作坊", "diy", "密室逃脫", "射箭", "滑雪", "潛水", "浮潛", "衝浪", "攀岩", "健身房", "瑜珈", "溫泉會館") 
    },
    @{ 
        Category = "戶外/生活購物"
        Keywords = @("戶外", "裝備", "登山", "露營用品", "運動用品", "百貨", "商場", "outlet", "mall", "plaza", "mart", "超市", "量販", "全聯", "家樂福", "大潤發", "costco", "好市多", "唐吉訶德", "donki", "藥妝", "屈臣氏", "康是美", "松本清", "服飾", "服裝", "選品", "選物", "雜貨", "古著", "書店", "唱片", "伴手禮", "禮品", "名產", "文具", "玩具", "扭蛋", "7-11", "全家", "超商", "鞋", "包袋", "飾品", "ikea", "無印良品", "muji", "uniqlo", "gu", "迪卡儂", "decathlon", "hme") 
    },
    @{ 
        Category = "交通/設施"
        Keywords = @("車站", "捷運", "火車站", "高鐵", "機場", "station", "airport", "碼頭", "港口", "停車場", "停車", "parking", "加油站", "休息站", "服務區", "交流道", "租車", "轉運站", "醫院", "診所", "藥局", "郵局", "銀行") 
    },
    @{ 
        Category = "咖啡廳"
        Keywords = @("咖啡", "cafe", "coffee", "roaster", "拿鐵", "手沖", "喫茶", "豆商", "烘豆") 
    },
    @{ 
        Category = "甜點/烘焙"
        Keywords = @("甜點", "蛋糕", "烘焙", "冰品", "冰店", "刨冰", "豆花", "泡芙", "肉桂捲", "下午茶", "芋圓", "bakery", "dessert", "可麗露", "司康", "舒芙蕾", "鯛魚燒", "大福", "布丁", "抹茶", "可頌", "麵包", "甜甜圈", "donut", "餅乾", "派", "塔", "鬆餅", "馬卡龍", "蛋塔", "車輪餅", "雞蛋糕", "冰淇淋", "gelato", "ice cream", "水果切盤", "果汁", "飲品", "手搖", "飲料") 
    },
    @{ 
        Category = "酒吧/餐酒館"
        Keywords = @("酒吧", "bar", "cocktail", "調酒", "精釀", "pub", "居酒屋", "bistro", "餐酒館", "串燒", "啤酒", "beer", "lounge", "炭火居酒屋") 
    },
    @{ 
        Category = "早餐/早午餐"
        Keywords = @("早餐", "早午餐", "brunch", "蛋餅", "三明治", "漢堡", "吐司", "貝果", "晨間", "美而美", "麥味登", "弘爺") 
    },
    @{ 
        Category = "景點"
        Keywords = @("景點", "公園", "步道", "海灘", "海水浴場", "古蹟", "博物館", "風景區", "觀景台", "瀑布", "寺", "廟", "老街", "碼頭", "夜景", "農場", "文創園區", "美術館", "神社", "展望台", "castle", "park", "temple", "shrine", "宮", "渡船", "纜車", "水族館", "牧場", "林場", "觀光工廠", "遺址", "吊橋", "森林", "國家公園", "植物園", "動物園", "燈塔", "秘境", "山", "嶺", "谷", "坪", "鼻", "岬", "潭", "溪", "湖", "坑", "瀑") 
    },
    @{ 
        Category = "小吃"
        Keywords = @("小吃", "肉圓", "魯肉飯", "滷肉飯", "米粉", "麵線", "雞排", "鹹酥雞", "水餃", "包子", "臭豆腐", "夜市", "炒飯", "牛肉麵", "湯包", "刈包", "胡椒餅", "蔥油餅", "肉羹", "意麵", "黑白切", "鴨肉", "火雞肉飯", "筒仔米糕", "碗粿", "米糕", "熱炒", "關東煮", "煎包", "水煎包", "便當", "涼麵", "潤餅", "燒餅", "油條", "炭烤", "烤玉米", "滷味", "鹽水雞", "麻辣燙", "羹", "餛飩", "鍋貼", "麵攤", "扁食", "蚵仔煎", "肉粽", "粽子", "當歸鴨", "豬腳", "肉燥", "切仔麵") 
    },
    @{ 
        Category = "餐廳"
        Keywords = @("餐廳", "料理", "鍋", "火鍋", "燒肉", "牛排", "義大利麵", "日式", "壽司", "拉麵", "泰式", "韓式", "食堂", "披薩", "pizza", "pasta", "烤肉", "海鮮", "割烹", "定食", "生魚片", "美食", "合菜", "港式", "茶餐廳", "鐵板燒", "咖哩", "鰻魚", "壽喜燒", "麻辣鍋", "燒烤", "居食屋", "restaurant", "dining", "kitchen", "buffet", "吃到飽", "羊肉爐", "薑母鴨", "烤鴨", "粵菜", "川菜", "湘菜", "蔬食", "素食", "丼飯", "燉飯", "排餐", "餐館", "飯館", "廚房", "麵館", "餐", "食", "飯", "麵", "肉", "菜", "雞", "鴨", "鵝", "魚", "館", "坊", "舖") 
    }
)

$parsedList = [System.Collections.Generic.List[Object]]::new()
$counter = 0

foreach ($feat in $features) {
    $counter++
    $props = $feat.properties
    $loc = $props.location

    $name = ""
    $address = ""
    $countryCode = ""

    if ($loc) {
        $name = $loc.name
        $address = $loc.address
        $countryCode = $loc.country_code
    }

    if (-not $name) {
        $name = $props.Title
    }
    if (-not $name) {
        if ($address) {
            $name = $address.Split(',')[0]
        } else {
            $name = "口袋地點 $counter"
        }
    }

    $url = $props.google_maps_url
    $lat = $null
    $lng = $null
    if ($feat.geometry -and $feat.geometry.coordinates) {
        $lng = [double]$feat.geometry.coordinates[0]
        $lat = [double]$feat.geometry.coordinates[1]
    }

    if (-not $url) {
        if ($lat -ne $null -and $lng -ne $null) {
            $url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng"
        } else {
            $url = "https://www.google.com/maps/search/?api=1&query=" + [System.Uri]::EscapeDataString("$name $address")
        }
    }

    $dateStr = $props.date
    $createdAt = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($dateStr) {
        try {
            $parsedDate = [DateTimeOffset]::Parse($dateStr)
            $createdAt = $parsedDate.ToUnixTimeMilliseconds()
        } catch {}
    }

    # 地區判定
    $scope = "TW"
    $region = "其他"
    $fullSearchText = "$name $address"

    if ($countryCode -and $countryCode -ne "TW") {
        $scope = "INTL"
        if ($countryCodeMap.ContainsKey($countryCode)) {
            $region = $countryCodeMap[$countryCode]
        } else {
            $region = "其他海外"
        }
    } else {
        $matchedIntl = $false
        foreach ($ik in $intlKeywords) {
            foreach ($kw in $ik.Keywords) {
                if ($fullSearchText -match [regex]::Escape($kw)) {
                    $scope = "INTL"
                    $region = $ik.Name
                    $matchedIntl = $true
                    break
                }
            }
            if ($matchedIntl) { break }
        }

        if (-not $matchedIntl) {
            $scope = "TW"
            $region = "其他"
            foreach ($tc in $twCounties) {
                $matchedCounty = $false
                foreach ($kw in $tc.Keywords) {
                    if ($fullSearchText -match [regex]::Escape($kw)) {
                        $region = $tc.Short
                        $matchedCounty = $true
                        break
                    }
                }
                if ($matchedCounty) { break }
            }
        }
    }

    # 分類判定 (不再強行預設為餐廳)
    $category = "其他"
    foreach ($r in $rules) {
        $found = $false
        foreach ($kw in $r.Keywords) {
            if ($fullSearchText -match [regex]::Escape($kw)) {
                $category = $r.Category
                $found = $true
                break
            }
        }
        if ($found) { break }
    }

    $placeObj = [PSCustomObject]@{
        id = "star_$counter"
        name = $name
        address = $address
        scope = $scope
        region = $region
        category = $category
        lat = $lat
        lng = $lng
        url = $url
        note = ""
        createdAt = $createdAt
    }

    $parsedList.Add($placeObj)
}

$outputJson = $parsedList | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outputPath, $outputJson, [System.Text.Encoding]::UTF8)

$dataJsContent = "window.PEGGY_STARRED_PLACES = " + $outputJson + ";"
[System.IO.File]::WriteAllText($dataJsPath, $dataJsContent, [System.Text.Encoding]::UTF8)

Write-Host "成功完成重新分類！"
Write-Host "`n=== 分類分佈最新統計 ==="
$catGroup = $parsedList | Group-Object category | Sort-Object Count -Descending
foreach ($cg in $catGroup) {
    Write-Host "$($cg.Name): $($cg.Count) 筆"
}

# 檢查 HME
$hmeCheck = $parsedList | Where-Object { $_.name -match "HME|百岳" }
Write-Host "`n=== 檢查 HME 百岳戶外裝備 ==="
foreach ($h in $hmeCheck) {
    Write-Host "$($h.name) -> 最新分類: $($h.category) (地區: $($h.region))"
}
