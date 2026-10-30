[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$inputPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\places.json"
$outputPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\places.json"
$dataJsPath = "C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\data.js"

$rawText = [System.IO.File]::ReadAllText($inputPath, [System.Text.Encoding]::UTF8)
$places = $rawText | ConvertFrom-Json

Write-Host "讀取總筆數: $($places.Count)"

$rules = @(
    @{
        Category = "住宿/飯店"
        Keywords = @("hotel", "飯店", "酒店", "民宿", "旅館", "inn", "resort", "hostel", "villa", "渡假村", "露營區", "露營地", "露營", "營地", "青年旅館", "會館", "商旅", "旅店", "b&b", "guesthouse", "stay", "lodge", "glamping", "motel", "湯屋", "溫泉會館", "nest")
    },
    @{
        Category = "按摩/SPA/體驗"
        Keywords = @("massage", "spa", "按摩", "指壓", "油壓", "泰式按摩", "芳療", "水療", "美甲", "美睫", "採耳", "工作坊", "體驗", "diy", "密室逃脫", "射箭", "滑雪", "潛水", "浮潛", "衝浪", "攀岩", "健身房", "瑜珈", "卡丁車", "彈跳工廠", "保齡球", "射擊", "漆彈")
    },
    @{
        Category = "咖啡廳"
        Keywords = @("咖啡", "cafe", "café", "coffee", "roaster", "拿鐵", "手沖", "喫茶", "豆商", "烘豆", "espresso", "茶莊", "茶坊", "茶行", "茶舍", "茶館", "品茶", "茶藝", "tea house", "teahouse", "tea room", "matcha house", "茶屋", "akha ama", "specialty coffee", "cold brew", "秋 穗", "淺川", "mars.cnx")
    },
    @{
        Category = "甜點/烘焙"
        Keywords = @("甜點", "蛋糕", "烘焙", "冰品", "冰店", "刨冰", "剉冰", "雪花冰", "芋冰", "冰城", "冰室", "豆花", "泡芙", "肉桂捲", "下午茶", "芋圓", "bakery", "dessert", "可麗露", "司康", "scone", "舒芙蕾", "鯛魚燒", "大福", "布丁", "抹茶", "matcha", "可頌", "croissant", "麵包", "甜甜圈", "donut", "餅乾", "派", "塔", "鬆餅", "馬卡龍", "蛋塔", "車輪餅", "紅豆餅", "雞蛋糕", "冰淇淋", "gelato", "ice cream", "水果切盤", "果汁", "手搖", "飲料", "菠蘿油", "杏仁", "燒仙草", "愛玉", "白糖粿", "麻糬", "boulangerie", "pâtisserie", "patisserie", "芋餅", "餅行", "糕餅", "餅舖", "糖水", "甜品", "喫冰", "pan stock", "parlor", "パーラー", "mango sticky rice", "kanom", "kanomwan", "sticky rice", "pastry", "bread", "waffle", "crepe", "chiffon", "鳳李冰", "糖")
    },
    @{
        Category = "早餐/早午餐"
        Keywords = @("早餐", "早點", "早午餐", "brunch", "brekkie", "蛋餅", "三明治", "三明主義", "漢堡", "吐司", "toast", "貝果", "bagel", "晨間", "美而美", "麥味登", "弘爺", "炭烤土司", "碳烤土司", "飯糰")
    },
    @{
        Category = "酒吧/餐酒館"
        Keywords = @("酒吧", "bar", "cocktail", "調酒", "精釀", "pub", "居酒屋", "bistro", "餐酒館", "串燒", "啤酒", "beer", "lounge", "炭火居酒屋", "營酒", "酒場", "酌", "chill")
    },
    @{
        Category = "交通/設施"
        Keywords = @("車站", "捷運", "火車站", "高鐵", "機場", "station", "airport", "碼頭", "港口", "停車場", "停車", "parking", "加油站", "休息站", "服務區", "交流道", "租車", "轉運站", "醫院", "診所", "藥局", "郵局", "銀行", "運動中心", "體育館", "exchange", "money exchange", "currency", "superrich", "換匯", "換錢")
    },
    @{
        Category = "小吃"
        Keywords = @("小吃", "肉圓", "魯肉飯", "滷肉飯", "米粉", "麵線", "雞排", "鹹酥雞", "水餃", "包子", "臭豆腐", "夜市", "炒飯", "牛肉麵", "湯包", "刈包", "胡椒餅", "蔥油餅", "肉羹", "意麵", "黑白切", "鴨肉", "火雞肉飯", "筒仔米糕", "碗粿", "米糕", "熱炒", "關東煮", "煎包", "水煎包", "便當", "涼麵", "潤餅", "燒餅", "油條", "炭烤", "烤玉米", "滷味", "鹽水雞", "麻辣燙", "羹", "餛飩", "鍋貼", "麵攤", "扁食", "蚵仔煎", "肉粽", "粽子", "當歸鴨", "豬腳", "肉燥", "切仔麵", "蒸餃", "抄手", "豬血湯", "豆富", "豆腐", "包仔", "水晶餃", "香腸", "米製品", "米粿", "粿", "草仔粿", "酸辣粉", "冬粉", "麵", "粉", "排骨酥", "雞肉飯", "春捲", "生炒花枝", "鱔魚意麵", "土魠魚", "虱目魚", "抓餅", "蔥抓餅", "餡餅", "鹹粥", "清粥", "肉粥", "排骨湯", "四神湯", "甜不辣", "快餐", "炸醬麵", "麻醬麵", "乾麵", "湯麵", "陽春麵", "排骨飯", "爌肉飯", "焢肉飯", "饅頭", "鳳爪", "chicken rice", "pork leg rice", "pork rice", "pad thai", "khao soi", "noodle", "beef noodle", "boat noodle", "tom yum", "som tum", "roti", "satay", "bánh mì", "banh mi", "pho", "bun cha", "kuay teaw", "kaprao", "林老五")
    },
    @{
        Category = "景點"
        Keywords = @("景點", "公園", "步道", "海灘", "海水浴場", "古蹟", "博物館", "風景區", "觀景台", "瀑布", "老街", "碼頭", "夜景", "農場", "文創園區", "美術館", "神社", "展望台", "castle", "park", "temple", "shrine", "宮", "渡船", "纜車", "水族館", "牧場", "林場", "觀光工廠", "遺址", "吊橋", "森林", "國家公園", "植物園", "動物園", "燈塔", "秘境", "山", "嶺", "谷", "坪", "鼻", "岬", "潭", "溪", "湖", "坑", "瀑", "岩", "岩洞", "洞", "泉", "冷泉", "溫泉", "自行車道", "鐵道", "燈會", "寺", "廟", "天主堂", "教堂", "wat", "sanctuary", "pagoda", "palace", "market", "night market", "walking street", "bazaar", "市集", "市集", "coconut market", "morning market", "baankangwat", "觀景", "秘境")
    },
    @{
        Category = "戶外/生活購物"
        Keywords = @("戶外", "裝備", "登山", "露營用品", "運動用品", "百貨", "商場", "outlet", "mall", "plaza", "mart", "超市", "量販", "全聯", "家樂福", "大潤發", "costco", "好市多", "唐吉訶德", "donki", "藥妝", "屈臣氏", "康是美", "松本清", "服飾", "服裝", "選品", "選物", "雜貨", "古著", "書店", "唱片", "伴手禮", "名產", "文具", "玩具", "扭蛋", "7-11", "全家", "超商", "鞋", "包袋", "飾品", "ikea", "無印良品", "muji", "uniqlo", "gu", "迪卡儂", "decathlon", "hme", "百岳", "農民直銷站", "商店", "直銷站")
    },
    @{
        Category = "餐廳"
        Keywords = @("餐廳", "料理", "鍋", "火鍋", "燒肉", "牛排", "義大利麵", "日式", "壽司", "拉麵", "泰式", "韓式", "食堂", "披薩", "pizza", "pasta", "烤肉", "海鮮", "割烹", "定食", "生魚片", "美食", "合菜", "港式", "茶餐廳", "鐵板燒", "咖哩", "curry", "鰻魚", "鰻", "壽喜燒", "麻辣鍋", "燒烤", "居食屋", "restaurant", "dining", "kitchen", "buffet", "吃到飽", "羊肉爐", "薑母鴨", "烤鴨", "粵菜", "川菜", "湘菜", "蔬食", "素食", "丼", "丼飯", "燉飯", "排餐", "餐館", "飯館", "廚房", "麵館", "grill", "steak", "bbq", "沾麵", "烏龍麵", "天婦羅", "炸豬排", "漢堡", "burger", "台菜", "私廚", "無菜單", "海產", "活海鮮", "串炸", "料亭", "日料", "酒樓", "大飯店", "餃子", "燒臘", "越式", "河粉", "pho", "坦都理", "印尼料理", "印度料理", "土耳其料理", "義式", "法式", "法式料理", "西班牙料理", "suki", "shabu", "hotpot", "halal", "seafood", "cuisine", "fine dining", "baan landai", "kratiem", "kung yim", "野味", "樂蔬", "威利與查理", "餐", "食", "飯", "麵", "肉", "菜", "雞", "鴨", "鵝", "魚", "館", "坊", "舖", "樓", "閣", "軒", "莊", "堂", "舍", "亭", "居", "家", "記")
    }
)

$updatedCount = 0

foreach ($p in $places) {
    $searchTarget = "$($p.name) $($p.address) $($p.note)".ToLower()

    $newCat = "其他"
    foreach ($r in $rules) {
        $matched = $false
        foreach ($kw in $r.Keywords) {
            if ($searchTarget.Contains($kw.ToLower())) {
                $newCat = $r.Category
                $matched = $true
                break
            }
        }
        if ($matched) { break }
    }

    if ($p.category -ne $newCat) {
        $p.category = $newCat
        $updatedCount++
    }
}

Write-Host "重新比對完成！共更新了 $updatedCount 筆地點的分類。"

Write-Host "`n=== 最新全分類分佈統計 ==="
$catGroup = $places | Group-Object category | Sort-Object Count -Descending
foreach ($cg in $catGroup) {
    Write-Host "$($cg.Name): $($cg.Count) 筆"
}

$outputJson = $places | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outputPath, $outputJson, [System.Text.Encoding]::UTF8)

$dataJsContent = "window.PEGGY_STARRED_PLACES = " + $outputJson + ";"
[System.IO.File]::WriteAllText($dataJsPath, $dataJsContent, [System.Text.Encoding]::UTF8)

Write-Host "`n已成功寫入 places.json 與 data.js！"
