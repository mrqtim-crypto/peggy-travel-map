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
        Keywords = @(
            "hotel", "飯店", "酒店", "民宿", "旅館", "inn", "resort", "hostel", "villa", "渡假村",
            "露營區", "露營地", "露營", "營地", "青年旅館", "會館", "商旅", "旅店", "b&b", "guesthouse",
            "stay", "lodge", "glamping", "motel", "湯屋", "溫泉會館", "nest", "背包客棧", "客棧",
            "旅宿", "小木屋", "heritance aarah", "sun siyam", "plumeria maldives", "sultan cave",
            "batur cabins", "camaya bali", "suites", "residence", "cozy house", "green tiger house",
            "紅點文旅", "桃城茶樣子", "文旅", "遛遛三星", "踏浪星辰", "峰州小木屋", "峯州小木屋", "山莊",
            "渡假", "度假", "露營車", "休閒農莊", "莊園俱樂部", "海岸行館", "上野之家", "hintok river camp",
            "camp", "帳篷", "行館"
        )
    },
    @{
        Category = "按摩/SPA/體驗"
        Keywords = @(
            "massage", "spa", "按摩", "指壓", "油壓", "泰式按摩", "芳療", "水療", "美甲", "美睫",
            "採耳", "工作坊", "體驗", "diy", "密室逃脫", "射箭", "滑雪", "潛水", "浮潛", "衝浪",
            "攀岩", "健身房", "瑜珈", "yoga", "卡丁車", "彈跳工廠", "保齡球", "射擊", "漆彈",
            "hanbok", "韓服", "沙灘車", "sup", "獨木舟", "賞鯨", "片場", "攝影器材",
            "wild rose yoga", "the touch", "花路韓服", "小島畫畫課", "潛規則", "星宇沙灘車",
            "足湯", "電棒燙", "hair", "美髮", "理髮", "燙髮", "染髮", "沙龍", "salon"
        )
    },
    @{
        Category = "咖啡廳"
        Keywords = @(
            "咖啡", "cafe", "café", "coffee", "roaster", "拿鐵", "手沖", "喫茶", "豆商", "烘豆",
            "espresso", "濃縮", "少一顆濃縮", "星巴克", "starbucks", "珈琲", "茶莊", "茶坊", "茶行",
            "茶舍", "茶館", "品茶", "茶藝", "tea house", "teahouse", "tea room", "matcha house",
            "茶屋", "茶室", "akha ama", "specialty coffee", "cold brew", "秋 穗", "淺川",
            "mars.cnx", "cộng cà phê", "cong ca phe", "caffeinerush", "avoccino", "83 koff", "83koff",
            "caffe", "珈琲花", "萬祝號", "木商珈琲", "喫茶三千", "吃茶三千", "揣茶", "隱茶", "樹夏飲事",
            "大和頓物所", "波哥", "ug 台南", "ug忠孝", "charlie thai tea", "万茶川", "丘森茶室", "吉曼",
            "gypt.mann", "獅球珈琲", "生活在他方", "媽媽嘴咖啤", "好咖", "人x人", "馥湘茶飲", "菊花香養生茶",
            "菊芝香", "薬師的私房紅茶", "藥師的私房紅茶", "一青苑手工茶殿", "淸水堂", "清水堂", "茶亭",
            "天空興波", "興波", "simple kaffa", "瑪黑家", "dog in town", "oneday wallflowers"
        )
    },
    @{
        Category = "甜點/烘焙"
        Keywords = @(
            "甜點", "蛋糕", "烘焙", "冰品", "冰店", "刨冰", "剉冰", "雪花冰", "芋冰", "冰城", "冰室",
            "豆花", "泡芙", "肉桂捲", "下午茶", "芋圓", "bakery", "dessert", "可麗露", "司康",
            "scone", "舒芙蕾", "鯛魚燒", "大福", "布丁", "抹茶", "matcha", "可頌", "croissant",
            "麵包", "甜甜圈", "donut", "餅乾", "派", "塔", "鬆餅", "馬卡龍", "蛋塔", "車輪餅",
            "紅豆餅", "雞蛋糕", "冰淇淋", "gelato", "ice cream", "水果切盤", "果汁", "手搖",
            "手搖杯", "飲料", "菠蘿油", "杏仁", "燒仙草", "仙草", "愛玉", "白糖粿", "麻糬",
            "boulangerie", "pâtisserie", "patisserie", "芋餅", "餅行", "糕餅", "餅舖", "糖水",
            "甜品", "喫冰", "pan stock", "parlor", "パーラー", "mango sticky rice", "kanom",
            "kanomwan", "sticky rice", "pastry", "bread", "waffle", "crepe", "chiffon", "鳳李冰",
            "提拉米蘇", "tiramisu", "dacomecca", "mignon", "boul'ange", "パン屋", "パン", "甘味屋",
            "菓子", "菓子工場", "綠豆蒜", "薏仁湯", "雪梅娘", "花生湯", "冰沙", "牛奶冰", "芒果牛奶冰",
            "木瓜牛奶", "牛乳大王", "牛乳", "霜淇淋", "冰菓室", "冰菓店", "冰枝店", "芋頭城", "冬瓜茶",
            "冬瓜伯", "實心蛋捲", "蛋捲", "蛋黃酥", "千層", "水果千層", "時飴", "布朗尼", "brownie",
            "after you", "sretsis", "brynja", "coco jj", "sweettime", "八號甜蜜", "siamaya chocolate",
            "chocolate", "巧克力", "chè", "bánh trôi", "xôi chè", "kem bơ", "nước thảo mộc",
            "奶茶", "珍珠奶茶", "珍奶", "珍煮丹", "迷客夏", "清心", "五十嵐", "50嵐", "拾豆屋",
            "白冷冰棒", "冰棒", "阿婆冰", "圓仔冰", "圓仔湯", "番薯圓", "水龜伯", "海找冰",
            "島民冰狗店", "豐春冰菓", "明新冰菓", "冰鄉", "春虫冰工場", "壽壽喜園", "中村藤吉",
            "淺草梅園", "午冬", "美美子", "煙囪捲", "夾心酥", "石頭餅", "木瓜王", "魏腐",
            "祥賀芒果牛奶冰", "西螺阿財湯圓雪泥冰", "恐龍嫩仙草", "泰成水果店", "toka", "阿丹芋頭牛奶冰沙",
            "順道菓子店", "炎術", "阿波伯楊桃汁", "東市楊桃冰", "劉湯圓", "果珍濃", "小赫霜淇淋",
            "和美冰菓室", "呷二嘴", "進來涼", "竹門鈺雪", "秋林牛乳大王", "南埕衖事", "古都木瓜牛奶",
            "顏太煮奶茶", "五甲地香酥芋泥球", "知更鳥巢鮮果茶飲", "花鳥川", "華氏77鮮果茶飲",
            "車埕冬瓜伯", "美崙紅茶", "佳興冰菓", "金龍 木瓜牛乳", "芋香園", "美香齋餅店",
            "波哥誠品", "bualoy", "cheevit cheeva", "雙連圓仔湯", "番薯市八寶圓仔冰", "冰的大本營",
            "純白小屋", "濃特慢", "creammm.t", "一等涼冬瓜", "金三益健康茶飲", "正興酥餅", "芋香園",
            "the mango garden", "沐沐茶旅", "83 koff", "tarnpawa", "cheevit cheeva", "白冷冰棒",
            "現切水果", "切水果", "冬瓜原汁", "甘味", "敘冰", "伴糖", "如意軒", "甘味處", "甜心",
            "折田菓舖", "淺草花月堂", "花月堂", "九鼎軒", "machi machi", "麥吉", "糖炒栗子", "栗子",
            "先麥", "太陽堂", "太陽餅", "芋頭酥", "地瓜酥", "花生糖", "糖果行", "奕順軒", "冰工坊",
            "芋頭冰", "不二坊", "餅家", "豆製所", "甜坊", "牛舌餅", "新嘉坡餐室", "珍多椰奶冰", "椰奶冰",
            "puritan", "菓舖", "連城記"
        )
    },
    @{
        Category = "早餐/早午餐"
        Keywords = @(
            "早餐", "早點", "早午餐", "brunch", "brekkie", "蛋餅", "三明治", "三明主義", "漢堡",
            "吐司", "toast", "貝果", "bagel", "晨間", "美而美", "麥味登", "弘爺", "炭烤土司",
            "碳烤土司", "飯糰", "egg drop", "不想早起", "豆漿店", "豆漿", "無名豆漿", "津津豆漿",
            "旭達豆漿", "百里香豆漿", "bills", "kfc", "肯德基", "麥當勞", "mcdonald", "喫堡",
            "早中餐", "meat up"
        )
    },
    @{
        Category = "酒吧/餐酒館"
        Keywords = @(
            "酒吧", "bar", "cocktail", "調酒", "精釀", "pub", "居酒屋", "bistro", "餐酒館",
            "串燒", "啤酒", "beer", "lounge", "炭火居酒屋", "營酒", "酒場", "酌", "chill",
            "酒飽", "大川酒飽", "daitoryo", "大統領", "sky36", "1900 club", "the haflington",
            "赤崁中藥行", "島東譯電所", "鈕扣倉庫", "新串", "iseya", "串炸", "串烤", "toriyoshi shoten",
            "oncor", "大川酒飽", "酒食", "狗一下", "居食酒堂", "居食屋"
        )
    },
    @{
        Category = "交通/設施"
        Keywords = @(
            "車站", "捷運", "火車站", "高鐵", "機場", "station", "airport", "碼頭", "港口",
            "停車場", "停車", "parking", "加油站", "中油", "台灣中油", "台塑石油", "休息站",
            "服務區", "交流道", "租車", "轉運站", "醫院", "診所", "藥局", "郵局", "銀行",
            "運動中心", "體育館", "exchange", "money exchange", "currency", "superrich",
            "換匯", "換錢", "bus terminal", "bus depot", "pier", "ferry landing", "管制站",
            "向陽管制站", "氣象站", "平交道", "新大阪", "心齋橋站", "京成上野", "新宿西口",
            "接待中心", "堺橋休息區", "kheha", "bus depot", "east passenger ferry landing",
            "領事事務局", "外交部"
        )
    },
    @{
        Category = "小吃"
        Keywords = @(
            "小吃", "肉圓", "魯肉飯", "滷肉飯", "米粉", "麵線", "雞排", "鹹酥雞", "水餃", "包子",
            "臭豆腐", "夜市", "炒飯", "牛肉麵", "湯包", "刈包", "胡椒餅", "蔥油餅", "肉羹", "意麵",
            "黑白切", "鴨肉", "火雞肉飯", "筒仔米糕", "碗粿", "米糕", "熱炒", "關東煮", "煎包",
            "水煎包", "便當", "涼麵", "潤餅", "燒餅", "油條", "炭烤", "碳烤", "烤玉米", "滷味",
            "魯味", "鹽水雞", "麻辣燙", "羹", "焿", "肉焿", "魷魚焿", "餛飩", "鍋貼", "麵攤", "扁食", "蚵仔煎", "肉粽",
            "粽子", "當歸鴨", "豬腳", "肉燥", "切仔麵", "蒸餃", "抄手", "豬血湯", "豆富", "豆腐",
            "包仔", "水晶餃", "香腸", "米製品", "米粿", "粿", "草仔粿", "酸辣粉", "冬粉", "麵",
            "粉", "排骨酥", "雞肉飯", "春捲", "生炒花枝", "鱔魚意麵", "土魠魚", "虱目魚", "抓餅",
            "蔥抓餅", "餡餅", "鹹粥", "清粥", "肉粥", "排骨湯", "四神湯", "甜不辣", "快餐", "炸醬麵",
            "麻醬麵", "乾麵", "湯麵", "陽春麵", "排骨飯", "爌肉飯", "焢肉飯", "饅頭", "鳳爪",
            "chicken rice", "pork leg rice", "pork rice", "pad thai", "khao soi", "noodle",
            "beef noodle", "boat noodle", "tom yum", "som tum", "roti", "satay", "bánh mì",
            "banh mi", "pho", "bun cha", "kuay teaw", "kaprao", "林老五", "蚵嗲", "扣仔嗲",
            "年糕", "辣炒年糕", "七里香", "南京七里香", "炸香菇", "蘿蔔糕", "芋頭糕", "小籠包",
            "米苔目", "米台目", "米干", "大陸餅", "阿粨", "面線町", "煎餃", "湯圓", "鹹湯圓",
            "大腸包小腸", "地瓜球", "辣脆腸", "三角骨", "大腸圈", "黑輪", "炸地瓜", "炸物", "炸香香",
            "蔥仔餅", "腿庫", "腳庫", "過橋米線", "許二姊", "西大發", "豆皮店", "豬心", "酥餅", "蚵仔炸",
            "蝦餅", "bæjarins beztu pylsur", "nai mong fry oyster", "pa tong go", "somtam",
            "khao gaeng", "khao moo daeng", "thịt xiên nướng", "bánh xèo", "bún chả",
            "phở", "一碗小", "小王煮瓜", "玉米", "糯米玉米", "東霖煎餃", "什錦湯", "香滿園", "小卷達人",
            "秋茂園炸地瓜", "本味瓦罐煨湯", "黃梨園點心店", "阿嘉小籠包", "阿榮蘿蔔糕", "清水米苔目",
            "大鬍子米干", "忠貞誠米干", "阿秀米干", "小云滇", "憶龍米苔目", "粨發粨粽", "苑裡煎餃",
            "蘇媽媽湯圓", "三沙灣米苔目", "阿田魯味", "社子島第一辣", "河南開封包", "北大行小籠包",
            "脆皮臭大王", "蔘源藥頭排骨", "點心攤", "大甲芋香包", "原住民不滿族", "第一名地瓜球",
            "老鄰長粄條店", "三合院&三合宴", "隱藏版三角骨", "花式蔥餅", "薯叔地瓜球", "來怡客捲餅",
            "鴻隆點心", "基隆菊姐大腸圈", "夢碗粥", "百成碳烤", "上好烤魯味", "玉井黑輪伯",
            "花魯米味", "熊阿姨炸芋頭餅", "香煎蔥仔餅", "卡滋脆皮豬", "秘滷椒麻鹵味", "條仔米苔目",
            "中州寮三角骨", "阿塗伯米苔目", "祥旺地瓜球", "洪維身蚵仔炸", "芳苑春霞蚵嗲", "春蚵嗲",
            "石頭鄉燜烤", "餵公子吃餅", "張秀雄米苔目", "光興腿庫", "金花點心攤", "宏珍雲南過橋米線",
            "國旗屋米干店", "度老命蝦餅", "秀里蚵嗲", "品香心肝湯", "南方澳無名蝦餅", "大胖豬心",
            "banana rotee", "bánh mỳ", "roasted honey glazed pork", "jad jan", "pantaree",
            "khao gaeng jek pui", "pa tong go savoey", "鵝肉", "鵝肉攤", "鵝肉擔", "油飯", "菜包",
            "春來菜包", "鄒記菜包", "魚丸", "白斬雞", "傳統米食", "紫菜包飯", "肉餅", "海南雞飯",
            "鴨魯飯", "沙茶牛肉", "肉羹慶", "肉焿慶", "太祖魷魚焿", "牛肉湯", "羊肉湯", "草魚湯",
            "鮮魚湯", "魚湯", "魚皮", "魚肚", "豬肉湯飯", "湯飯", "血腸", "鷄脚翅", "雞腳翅",
            "鷄爪", "雞爪凍", "雞腳凍", "軟骨飯", "蘿蔔絲餅", "韮菜餅", "韭菜餅", "韭菜盒",
            "韭菜盒子", "菜盒", "生炒羊肉", "炒牛肉", "炒羊肉", "鹽酥雞", "炸雞", "烤雞", "海南雞",
            "麻油雞", "雞肉串", "大魷魚", "烤魷魚", "鼎邊銼", "蚵肉炸", "豬油拌飯", "蝦仁飯",
            "飯湯", "牛肉捲餅", "雞絲飯", "葱油餅", "大餅", "臭脯餅", "肉丸", "頭骨肉", "菜脯雞",
            "九尾雞", "好吃雞肉", "五花肉飯", "豆干", "蝦捲", "台包", "民雄肉包", "阿灶伯", "羊肉榮",
            "雞肉大王", "三多屋", "爸爸嘴", "滷鵝", "鹵鵝", "沙嗲", "松記沙嗲", "肉骨茶", "鬼頭刀",
            "紫菜包飯"
        )
    },
    @{
        Category = "戶外/生活購物"
        Keywords = @(
            "戶外", "裝備", "登山", "露營用品", "運動用品", "百貨", "商場", "outlet", "mall",
            "plaza", "mart", "超市", "量販", "全聯", "家樂福", "大潤發", "costco", "好市多",
            "唐吉訶德", "donki", "藥妝", "屈臣氏", "康是美", "松本清", "服飾", "服裝", "選品",
            "選物", "雜貨", "古著", "書店", "唱片", "伴手禮", "名產", "文具", "玩具", "扭蛋",
            "7-11", "7-eleven", "全家", "超商", "美廉社", "鞋", "包袋", "飾品", "ikea",
            "無印良品", "muji", "uniqlo", "gu", "迪卡儂", "decathlon", "hme", "百岳",
            "農民直銷站", "商店", "直銷站", "商行", "商號", "油廠", "中藥行", "藥房", "藥行",
            "農會", "select shop", "fotoshop", "object", "bracket table", "mlb", "yodobashi",
            "lalaport", "siam paragon", "central world", "big c", "foodland", "lotus",
            "mixt chatuchak", "大巴扎", "karmakamet", "iconsiam", "biccamera", "kitte",
            "takeya", "tokyu department", "維納斯城堡", "diver city", "aqua city", "caretta",
            "集貨場", "小賣所", "名品城", "漢市場", "剝皮辣椒", "洋行", "生活驛站", "周桂發",
            "h.chinda design", "หวายน้ำผึ้ง", "欣欣商號", "重成商號", "聯翔餅店", "avivere",
            "又又美fotoshop", "銅鑼鄉農會", "金豐春商行", "洪春梅西點器具店", "foldie", "lopia",
            "順成油廠", "仰角舶物", "義竹鄉農會", "girls shop", "attention", "aigle",
            "newsstand", "95樂府", "bingo shop", "pull&bear", "roshop", "uv100",
            "玉井青果集貨場", "阿嬤的珍藏", "黃永生藥房", "姚德和", "吉元藥行", "56deco",
            "sly", "cinq", "coeur de coeur", "艾妥列", "tokyu department store",
            "wako aqua city", "papaya studio", "quang huy gemstone", "líu lô arts",
            "chiang mai cosmetics", "rabbit8friends", "grandma hanjin chikan shop",
            "吉慶行", "decorte", "ario 倉敷", "食品行", "食品", "青草舖", "垂坤", "泡菜",
            "東京中城", "midtown", "蓋頌阿瑪琳", "gaysorn", "肉鬆", "肉乾", "肉紙", "江記華隆",
            "水產", "阿布潘水產"
        )
    },
    @{
        Category = "景點"
        Keywords = @(
            "景點", "公園", "步道", "海灘", "海水浴場", "古蹟", "博物館", "風景區", "觀景台", "瀑布",
            "老街", "碼頭", "夜景", "農場", "文創園區", "園區", "美術館", "神社", "展望台",
            "castle", "park", "temple", "shrine", "宮", "渡船", "纜車", "水族館", "牧場",
            "林場", "觀光工廠", "觀光工場", "遺址", "吊橋", "森林", "國家公園", "植物園", "動物園",
            "燈塔", "lighthouse", "秘境", "祕境", "山", "嶺", "谷", "坪", "鼻", "岬", "潭",
            "溪", "湖", "坑", "瀑", "岩", "岩洞", "洞", "泉", "冷泉", "溫泉", "自行車道",
            "鐵道", "燈會", "寺", "廟", "天主堂", "教堂", "church", "cathedral", "wat",
            "sanctuary", "pagoda", "palace", "market", "night market", "walking street",
            "bazaar", "市集", "集市", "coconut market", "morning market", "baankangwat",
            "觀景", "beach", "韓屋村", "月精橋", "瞻星臺", "大陵園", "天馬塚", "皇理團路",
            "校村", "風車聚落", "沙灘", "日落大道", "一線天", "漁港", "生命之樹", "小王子像",
            "grand world", "三十六古街", "tha phae gate", "chợ đêm", "an bang beach",
            "千本櫻", "出張所", "藝術園區", "art center", "大天池", "天池", "砂灘", "櫻花林",
            "櫻花", "椰林大道", "陸連島", "大草原", "草原", "高地", "劍龍稜", "鋸齒稜", "聖殿",
            "聖母聖殿", "月世界", "千野村", "創意生活園區", "森活村", "大社", "日吉大社",
            "春日大社", "蛤板灣", "美人沙灘", "觀音石", "花瓶石", "網美老木", "落日灣", "長生橋",
            "遊客中心", "獵鷹尖", "古道", "慶修院", "遊憩區", "海灣", "小白屋", "小野柳",
            "金城武樹", "沙洲", "梯田", "天空之鏡", "城堡", "巨人之手", "the grotto",
            "emerald pool", "blue pool", "elephants world", "dyrhólaey", "kirkjufjara",
            "太陽航海者", "tree house", "ancient theater", "theatre", "sunset view point",
            "古城", "72府古城", "water market", "水上市場", "真理聖殿", "erawan museum",
            "safari world", "清水斷崖", "弘前城", "合掌造", "兼六園", "天橋立", "姬路城",
            "環球影城", "迪士尼", "disneyland", "伊根舟屋", "美觀地區", "kinkaku-ji",
            "空中庭園", "平等院", "伏見十石舟", "江之島", "大佛", "後樂園", "井之頭",
            "八公像", "伯朗大道", "大學", "校區", "落羽松", "女兒橋", "海天橋", "青池",
            "萬座毛", "賞螢", "金森紅磚倉庫", "observatory", "高原教會", "綺緣樟腦精油觀光工場",
            "桶盤堀漁港", "新光黃昏市場", "假日之森", "小森之歌", "st. joseph cathedral",
            "huyen khong cave", "白石川堤", "竹東文創藝術村", "水蛙窟大草原", "埔頂大草原",
            "101高地", "田寮月世界", "勝利星村", "比西里岸部落", "雲中街文創聚落", "摩爾花園",
            "許願鐘", "國立東華大學", "向日廣場", "同樂休閒綠園道", "粮田集市", "太麻里平交道",
            "三仙臺遊客中心", "台泥daka園區", "小狗灣入口", "北回歸線地標", "觀光果園",
            "梅峰古道", "亞洲大學", "水源市場", "金樽遊憩區", "加母子灣", "華源海灣",
            "加路蘭遊憩區", "頂頭額沙洲", "莫內秘密花園", "新社梯田", "72府古城", "古城",
            "大城水上市場", "空叻瑪榮水上市場", "安帕瓦水上市場", "巧克力村", "暹羅古城",
            "石門班哨角休憩區", "嘉德花田", "新營美術園區", "農田水利環境教育園區",
            "觀音草漯沙丘", "福寶生態教育園區", "社腳里落羽松林", "白金青池", "東清祕境",
            "monterey lumer church", "鎌倉大佛殿高德院", "sakurai futamigaura", "錦市場",
            "黑門市場", "一心行的大櫻花樹", "忠犬八公像", "富士電視台", "東京迪士尼樂園", "井之頭池",
            "alpine coaster", "hverir", "papa beach", "tha maharaj", "wfft", "wildlife",
            "uma pakel", "王權瑪哈納功", "南鯤鯓代天府", "代天府", "大溪老茶廠", "大三巴", "牌坊",
            "臺灣玻璃館", "玻璃館", "蘇維拉莊園", "石之教會", "記念堂", "nanatanigawa",
            "pavilion", "sumeru", "botanical garden", "วัด", "大菜市", "西門市場", "香料館",
            "熊空茶園", "木工坊", "農莊", "紀念館", "風力發電廠", "elephants' home", "酒莊",
            "藏酒酒莊"
        )
    },
    @{
        Category = "餐廳"
        Keywords = @(
            "餐廳", "料理", "鍋", "火鍋", "燒肉", "牛排", "義大利麵", "日式", "壽司", "拉麵",
            "泰式", "韓式", "食堂", "披薩", "pizza", "pasta", "烤肉", "海鮮", "割烹", "定食",
            "生魚片", "美食", "合菜", "港式", "茶餐廳", "鐵板燒", "咖哩", "curry", "鰻魚", "鰻",
            "壽喜燒", "麻辣鍋", "燒烤", "居食屋", "restaurant", "dining", "kitchen", "buffet",
            "吃到飽", "羊肉爐", "薑母鴨", "烤鴨", "粵菜", "川菜", "湘菜", "蔬食", "素食", "丼",
            "丼飯", "燉飯", "排餐", "餐館", "飯館", "廚房", "麵館", "grill", "steak", "bbq",
            "沾麵", "烏龍麵", "天婦羅", "炸豬排", "漢堡", "burger", "台菜", "私廚", "無菜單",
            "海產", "活海鮮", "料亭", "日料", "酒樓", "大飯店", "餃子", "燒臘", "越式", "河粉",
            "坦都理", "印尼料理", "印度料理", "土耳其料理", "義式", "法式", "法式料理", "西班牙料理",
            "suki", "shabu", "hotpot", "halal", "seafood", "cuisine", "fine dining",
            "baan landai", "kratiem", "kung yim", "野味", "樂蔬", "威利與查理", "shake shack",
            "83獬豸", "gyodong", "geosong", "short ribs", "solsot", "vua chả cá", "vua cha ca",
            "butcher", "都一處", "zaap", "zaaptaipei", "海饕", "牛庵", "窯烤", "海味",
            "supersate", "shokudo", "温體牛", "溫體牛", "saffron 46", "若柳一筋", "yakiniku",
            "smokehouse", "烤乳豬", "田中漁夫", "灶咖", "道樂屋台", "女娘的店", "阿含thai",
            "jeh o chula", "somtum der", "savoey", "ploy talay", "eat sight story",
            "sala rattanakosin", "king tacos", "一蘭", "ichiran", "阿夫利", "afuri", "matsuya",
            "松屋", "磯丸水產", "磯丸水産", "ginza hinaiya", "the house by ginger", "小小麥",
            "jungle醬狗", "hyanghwajeong", "bokgil", "la badiane", "b samcook", "tong tem toh",
            "fohhide", "neng roasted pork", "chiang mai horumon", "hot pot by jay so",
            "天涯海餃", "神州窯烤", "北平半畝園", "旗遇海味", "疆羊大道", "無餓不坐", "覓覓飢地",
            "塩琉", "我愛希臘捲餅", "99海瑞特", "ăn thôi", "伊禾白湯", "akariya yakiniku",
            "bogart's smokehouse", "三姊妹 越南烤乳豬", "漁人灶咖", "羊陶", "單賣共和國",
            "紅心女王宴會大廳", "toriyoshi", "ginza hinaiya", "和成豐", "supanniga",
            "kung phuean praew", "truku的屋頂", "南洋風高腳屋", "朱雀", "suzaku", "小館",
            "餐飲", "飲食店", "牛家莊", "peppino", "三姐妹餐飲", "匡師傅", "三嶋亭", "yayoi軒",
            "やよい軒", "一風堂", "樂軒和牛", "和牛", "客家菜", "螞蟻家", "puradak", "濟州家",
            "土雞城", "the slice shop", "汕頭館", "爐端", "魚男", "川客菜", "煲仔飯", "炒鱔魚",
            "部落廚坊", "廚坊", "ラーメン", "上海菜", "私房菜", "ステーキ", "甕仔雞", "蘇杭",
            "秦味館", "香滿樓", "小鴨片", "和食", "大閘蟹", "酸菜魚", "食坊", "桶仔雞", "餐車",
            "餐坊", "kopitiam", "騷烤家", "胡椒白菜雞", "建興酒家", "aroi", "泰美", "彭家園",
            "膳坊", "茶樓", "旺龍館", "牛雜湯", "牛雜", "牛肉爐"
        )
    }
)

$updatedCount = 0

foreach ($p in $places) {
    # If the place is a pure dropped pin (e.g. name starts with "口袋地點" and address is empty), leave as "其他"
    if ($p.name -match '^口袋地點\s*\d*' -and [string]::IsNullOrWhiteSpace($p.address)) {
        if ($p.category -ne "其他") {
            $p.category = "其他"
            $updatedCount++
        }
        continue
    }

    $rawTarget = "$($p.name) $($p.address) $($p.note)"
    $normalizedTarget = $rawTarget.Normalize([System.Text.NormalizationForm]::FormKD).ToLower()

    $newCat = "其他"
    foreach ($r in $rules) {
        $matched = $false
        foreach ($kw in $r.Keywords) {
            $kwNorm = $kw.Normalize([System.Text.NormalizationForm]::FormKD).ToLower()
            if ($normalizedTarget.Contains($kwNorm)) {
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