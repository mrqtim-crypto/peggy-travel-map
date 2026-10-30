[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$inputPath = "c:\Users\ken03\Downloads\Takeout\地圖 (你的地點)\已儲存的地點.json"
$outputPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\places.json"
$dataJsPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\data.js"

Write-Host "讀取 Takeout JSON 檔案..."
$rawText = [System.IO.File]::ReadAllText($inputPath, [System.Text.Encoding]::UTF8)
$data = $rawText | ConvertFrom-Json
$features = $data.features
Write-Host "總筆數: $($features.Count)"

# 國外國碼對照表
$countryCodeMap = @{
    "JP" = "日本"
    "KR" = "韓國"
    "TH" = "泰國"
    "VN" = "越南"
    "IS" = "冰島"
    "TR" = "土耳其"
    "MO" = "澳門"
    "HK" = "香港"
    "ID" = "印尼"
    "MV" = "馬爾地夫"
    "SG" = "新加坡"
    "MY" = "馬來西亞"
    "CN" = "中國"
    "US" = "美國"
    "FR" = "法國"
    "IT" = "義大利"
    "GB" = "英國"
    "UK" = "英國"
    "DE" = "德國"
    "ES" = "西班牙"
    "AU" = "澳洲"
    "CA" = "加拿大"
    "CH" = "瑞士"
    "NL" = "荷蘭"
    "AT" = "奧地利"
    "NZ" = "紐西蘭"
    "PH" = "菲律賓"
}

# 國外地名/關鍵字對照
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

# 台灣 22 縣市定義 (嚴格依照順序比對)
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

# 分類關鍵字
$categoriesDef = @(
    @{ Name = "住宿/飯店"; Keywords = @("hotel", "飯店", "酒店", "民宿", "旅館", "inn", "resort", "hostel", "渡假村", "露營", "營地", "會館") },
    @{ Name = "咖啡廳"; Keywords = @("咖啡", "cafe", "coffee", "roaster", "拿鐵", "手沖", "喫茶", "豆商") },
    @{ Name = "小吃"; Keywords = @("小吃", "肉圓", "魯肉飯", "滷肉飯", "米粉", "麵線", "雞排", "鹹酥雞", "水餃", "包子", "臭豆腐", "夜市", "炒飯", "牛肉麵", "湯包", "刈包", "胡椒餅", "蔥油餅", "肉羹", "意麵", "黑白切", "鴨肉", "火雞肉飯", "筒仔米糕", "碗粿", "米糕", "熱炒", "關東煮", "煎包", "水煎包") },
    @{ Name = "甜點"; Keywords = @("甜點", "蛋糕", "烘焙", "冰品", "冰店", "刨冰", "豆花", "泡芙", "肉桂捲", "下午茶", "芋圓", "bakery", "dessert", "可麗露", "司康", "舒芙蕾", "鯛魚燒", "大福", "布丁", "抹茶", "可頌", "麵包", "甜甜圈", "donut", "餅乾", "派", "塔") },
    @{ Name = "早餐/早午餐"; Keywords = @("早餐", "早午餐", "brunch", "蛋餅", "三明治", "漢堡", "吐司") },
    @{ Name = "酒吧/餐酒館"; Keywords = @("酒吧", "bar", "cocktail", "調酒", "精釀", "pub", "居酒屋", "bistro", "餐酒館", "串燒") },
    @{ Name = "景點"; Keywords = @("景點", "公園", "步道", "海灘", "海水浴場", "古蹟", "博物館", "風景區", "山", "觀景台", "瀑布", "寺", "廟", "老街", "碼頭", "夜景", "溫泉", "農場", "文創園區", "美術館", "神社", "展望台", "castle", "park", "temple", "shrine", "宮", "渡船", "纜車", "水族館", "牧場", "瀑布", "林場", "工廠", "觀光工廠") },
    @{ Name = "餐廳"; Keywords = @("餐廳", "料理", "鍋", "火鍋", "燒肉", "牛排", "義大利麵", "日式", "壽司", "拉麵", "泰式", "韓式", "食堂", "披薩", "pizza", "pasta", "烤肉", "海鮮", "割烹", "定食", "生魚片", "美食", "合菜", "港式", "茶餐廳") }
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
            $name = "口袋名單地點 $counter"
        }
    }

    $url = $props.google_maps_url
    if (-not $url) {
        if ($feat.geometry -and $feat.geometry.coordinates) {
            $lng = $feat.geometry.coordinates[0]
            $lat = $feat.geometry.coordinates[1]
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

    # 1. 判斷 Scope (台灣 vs 國外) 與 地區名稱
    $scope = "TW"
    $region = "其他"
    $fullSearchText = "$name $address"

    # 先判斷國碼
    if ($countryCode -and $countryCode -ne "TW") {
        $scope = "INTL"
        if ($countryCodeMap.ContainsKey($countryCode)) {
            $region = $countryCodeMap[$countryCode]
        } else {
            $region = "其他海外"
        }
    } else {
        # 國碼為 TW 或空白，先檢查是否命中海外關鍵字
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

        # 若未命中海外，則歸入台灣，並細分各縣市
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

    # 2. 判斷分類
    $category = "餐廳"
    foreach ($c in $categoriesDef) {
        $matchedCat = $false
        foreach ($kw in $c.Keywords) {
            if ($fullSearchText -match [regex]::Escape($kw)) {
                $category = $c.Name
                $matchedCat = $true
                break
            }
        }
        if ($matchedCat) { break }
    }

    $placeObj = [PSCustomObject]@{
        id = "star_$counter"
        name = $name
        address = $address
        scope = $scope        # TW 或 INTL
        region = $region      # 縣市名 (基隆, 台北...) 或 國家名 (日本, 泰國...)
        category = $category
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

Write-Host "成功完成轉換！"
Write-Host "總筆數: $($parsedList.Count)"

Write-Host "`n=== 台灣 vs 國外 分佈 ==="
$scopeGroup = $parsedList | Group-Object scope
foreach ($sg in $scopeGroup) {
    Write-Host "$($sg.Name): $($sg.Count) 筆"
}

Write-Host "`n=== 台灣各縣市分佈 ==="
$twList = $parsedList | Where-Object { $_.scope -eq "TW" }
$twRegGroup = $twList | Group-Object region | Sort-Object Count -Descending
foreach ($rg in $twRegGroup) {
    Write-Host "$($rg.Name): $($rg.Count) 筆"
}

Write-Host "`n=== 國外各國分佈 ==="
$intlList = $parsedList | Where-Object { $_.scope -eq "INTL" }
$intlRegGroup = $intlList | Group-Object region | Sort-Object Count -Descending
foreach ($ig in $intlRegGroup) {
    Write-Host "$($ig.Name): $($ig.Count) 筆"
}
