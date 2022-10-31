import 'package:get/get.dart';

class CategoryController extends GetxController {
  static CategoryController get to => Get.find();

  final RxString _selectedCategoryInEng = 'none'.obs;
  String get currentCategoryInEng => _selectedCategoryInEng.value;
  String get currentCategoryInKor =>
      categoriesMapEngToKor[_selectedCategoryInEng.value]!;

  // 키로 _selectedCategoryInEng 값 설정
  void setNewCategoryWithEng(String newCategory) {
    if (categoriesMapEngToKor.keys.contains(newCategory)) {
      _selectedCategoryInEng.value = newCategory;
    }
  }

  // 값으로 _selectedCategoryInEng 값 설정
  void setNewCategoryWithKor(String newCategory) {
    if (categoriesMapEngToKor.values.contains(newCategory)) {
      _selectedCategoryInEng.value = categoriesMapKorToEng[newCategory]!;
    }
  }
}

const Map<String, String> categoriesMapEngToKor = {
  'none': '카테고리 선택',
  'furniture': '치킨',
  'electronics': '피자',
  'kids': '한식',
  'sports': '중식',
  'woman': '일식',
  'man': '분식',
  'makeup': '디저트',
  'desc': '아래 항목중에서 선택하세요, 없다면 상세글에 작성',
};

Map<String, String> categoriesMapKorToEng =
    categoriesMapEngToKor.map((key, value) => MapEntry(value, key));
