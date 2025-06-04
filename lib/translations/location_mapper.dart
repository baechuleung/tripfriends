class LocationMapper {
  // 국가 코드 매핑
  static final Map<String, Map<String, String>> countryNames = {
    'KR': {
      'KR': '한국',
      'JP': '韓国',
      'VN': 'Hàn Quốc',
      'TH': 'เกาหลีใต้',
      'TW': '韓國',
      'CN': '韩国',
      'HK': '韓國',
      'PH': 'South Korea',
      'GU': 'South Korea',
      'SG': 'South Korea'
    },
    'JP': {
      'KR': '일본',
      'JP': '日本',
      'VN': 'Nhật Bản',
      'TH': 'ญี่ปุ่น',
      'TW': '日本',
      'CN': '日本',
      'HK': '日本',
      'PH': 'Japan',
      'GU': 'Japan',
      'SG': 'Japan'
    },
    'VN': {
      'KR': '베트남',
      'JP': 'ベトナム',
      'VN': 'Việt Nam',
      'TH': 'เวียดนาม',
      'TW': '越南',
      'CN': '越南',
      'HK': '越南',
      'PH': 'Vietnam',
      'GU': 'Vietnam',
      'SG': 'Vietnam'
    },
    'TH': {
      'KR': '태국',
      'JP': 'タイ',
      'VN': 'Thái Lan',
      'TH': 'ประเทศไทย',
      'TW': '泰國',
      'CN': '泰国',
      'HK': '泰國',
      'PH': 'Thailand',
      'GU': 'Thailand',
      'SG': 'Thailand'
    },
    'TW': {
      'KR': '대만',
      'JP': '台湾',
      'VN': 'Đài Loan',
      'TH': 'ไต้หวัน',
      'TW': '臺灣',
      'CN': '台湾',
      'HK': '臺灣',
      'PH': 'Taiwan',
      'GU': 'Taiwan',
      'SG': 'Taiwan'
    },
    'CN': {
      'KR': '중국',
      'JP': '中国',
      'VN': 'Trung Quốc',
      'TH': 'จีน',
      'TW': '中國',
      'CN': '中国',
      'HK': '中國',
      'PH': 'China',
      'GU': 'China',
      'SG': 'China'
    },
    'HK': {
      'KR': '홍콩',
      'JP': '香港',
      'VN': 'Hồng Kông',
      'TH': 'ฮ่องกง',
      'TW': '香港',
      'CN': '香港',
      'HK': '香港',
      'PH': 'Hong Kong',
      'GU': 'Hong Kong',
      'SG': 'Hong Kong'
    },
    'PH': {
      'KR': '필리핀',
      'JP': 'フィリピン',
      'VN': 'Philippines',
      'TH': 'ฟิลิปปินส์',
      'TW': '菲律賓',
      'CN': '菲律宾',
      'HK': '菲律賓',
      'PH': 'Philippines',
      'GU': 'Philippines',
      'SG': 'Philippines'
    },
    'GU': {
      'KR': '괌',
      'JP': 'グアム',
      'VN': 'Guam',
      'TH': 'กวม',
      'TW': '關島',
      'CN': '关岛',
      'HK': '關島',
      'PH': 'Guam',
      'GU': 'Guam',
      'SG': 'Guam'
    },
    'SG': {
      'KR': '싱가포르',
      'JP': 'シンガポール',
      'VN': 'Singapore',
      'TH': 'สิงคโปร์',
      'TW': '新加坡',
      'CN': '新加坡',
      'HK': '新加坡',
      'PH': 'Singapore',
      'GU': 'Singapore',
      'SG': 'Singapore'
    },
    'ID': {
      'KR': '인도네시아',
      'EN': 'Indonesia',
      'JP': 'インドネシア',
      'CN': '印度尼西亚',
      'TW': '印尼',
      'VN': 'Indonesia',
      'TH': 'อินโดนีเซีย',
      'HK': '印尼',
      'PH': 'Indonesia',
      'GU': 'Indonesia',
      'SG': 'Indonesia'
    },
    'MY': {
      'KR': '말레이시아',
      'EN': 'Malaysia',
      'JP': 'マレーシア',
      'CN': '马来西亚',
      'TW': '馬來西亞',
      'VN': 'Malaysia',
      'TH': 'มาเลเซีย',
      'HK': '馬來西亞',
      'PH': 'Malaysia',
      'GU': 'Malaysia',
      'SG': 'Malaysia'
    },
  };

  // 베트남 도시 코드 매핑
  static final Map<String, Map<String, String>> vietnamCityNames = {
    'DNN': {
      'KR': '다낭',
      'EN': 'Da Nang',
      'JP': 'ダナン',
      'CN': '岘港',
      'TW': '峴港',
      'VN': 'Đà Nẵng',
      'TH': 'ดานัง',
      'HK': '峴港',
      'PH': 'Da Nang',
      'GU': 'Da Nang',
      'SG': 'Da Nang'
    },
    'NPT': {
      'KR': '나트랑',
      'EN': 'Nha Trang',
      'JP': 'ニャチャン',
      'CN': '芽庄',
      'TW': '芽莊',
      'VN': 'Nha Trang',
      'TH': 'ญาจาง',
      'HK': '芽莊',
      'PH': 'Nha Trang',
      'GU': 'Nha Trang',
      'SG': 'Nha Trang'
    },
    'NTR': {
      'KR': '나트랑',
      'EN': 'Nha Trang',
      'JP': 'ニャチャン',
      'CN': '芽庄',
      'TW': '芽莊',
      'VN': 'Nha Trang',
      'TH': 'ญาจาง',
      'HK': '芽莊',
      'PH': 'Nha Trang',
      'GU': 'Nha Trang',
      'SG': 'Nha Trang'
    },
    'DAD': {
      'KR': '달랏',
      'EN': 'Dalat',
      'JP': 'ダラット',
      'CN': '大叻',
      'TW': '大叻',
      'VN': 'Đà Lạt',
      'TH': 'ดาลัด',
      'HK': '大叻',
      'PH': 'Dalat',
      'GU': 'Dalat',
      'SG': 'Dalat'
    },
    'DLT': {
      'KR': '달랏',
      'EN': 'Dalat',
      'JP': 'ダラット',
      'CN': '大叻',
      'TW': '大叻',
      'VN': 'Đà Lạt',
      'TH': 'ดาลัด',
      'HK': '大叻',
      'PH': 'Dalat',
      'GU': 'Dalat',
      'SG': 'Dalat'
    },
    'PQC': {
      'KR': '푸꾸옥',
      'EN': 'Phu Quoc',
      'JP': 'フーコック',
      'CN': '富国',
      'TW': '富國',
      'VN': 'Phú Quốc',
      'TH': 'ฟูก๊วก',
      'HK': '富國',
      'PH': 'Phu Quoc',
      'GU': 'Phu Quoc',
      'SG': 'Phu Quoc'
    },
    'HAN': {
      'KR': '하노이',
      'EN': 'Hanoi',
      'JP': 'ハノイ',
      'CN': '河内',
      'TW': '河內',
      'VN': 'Hà Nội',
      'TH': 'ฮานอย',
      'HK': '河內',
      'PH': 'Hanoi',
      'GU': 'Hanoi',
      'SG': 'Hanoi'
    },
    'HCM': {
      'KR': '호치민',
      'EN': 'Ho Chi Minh City',
      'JP': 'ホーチミン',
      'CN': '胡志明市',
      'TW': '胡志明市',
      'VN': 'Thành phố Hồ Chí Minh',
      'TH': 'โฮจิมินห์',
      'HK': '胡志明市',
      'PH': 'Ho Chi Minh City',
      'GU': 'Ho Chi Minh City',
      'SG': 'Ho Chi Minh City'
    },
    'SGN': {
      'KR': '호치민',
      'EN': 'Ho Chi Minh City',
      'JP': 'ホーチミン',
      'CN': '胡志明市',
      'TW': '胡志明市',
      'VN': 'Thành phố Hồ Chí Minh',
      'TH': 'โฮจิมินห์',
      'HK': '胡志明市',
      'PH': 'Ho Chi Minh City',
      'GU': 'Ho Chi Minh City',
      'SG': 'Ho Chi Minh City'
    },
  };

  // 다른 국가의 도시들도 추가 가능
  static final Map<String, Map<String, Map<String, String>>> allCityNames = {
    'VN': vietnamCityNames,
    // 'TH': thailandCityNames,
    // 'PH': philippinesCityNames,
    // 등등...
  };

  /// 국가 코드와 언어에 따른 국가명 반환
  static String getCountryName(String countryCode, {String language = 'KR'}) {
    return countryNames[countryCode]?[language] ?? countryCode;
  }

  /// 국가 코드, 도시 코드, 언어에 따른 도시명 반환
  static String getCityName(String countryCode, String cityCode, {String language = 'KR'}) {
    return allCityNames[countryCode]?[cityCode]?[language] ?? cityCode;
  }

  /// 간편하게 베트남 도시명만 가져오기
  static String getVietnamCityName(String cityCode, {String language = 'KR'}) {
    return vietnamCityNames[cityCode]?[language] ?? cityCode;
  }
}