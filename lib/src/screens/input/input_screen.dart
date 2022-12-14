import 'dart:typed_data';

import 'package:beamer/beamer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../constants/data_keys.dart';
import '../../models/item_model.dart';
import '../../repo/image_storage.dart';
import '../../repo/item_service.dart';
import '../../states/user_controller.dart';
import '../../states/category_controller.dart';
import '../../states/select_image_controller.dart';
import '../../constants/common_size.dart';
import '../../widgets/warning_dialog.dart';
import 'multi_image_select.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final dividerCustom = Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[350],
      indent: padding_16,
      endIndent: padding_16);

  final underLineBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent));

  bool _suggestPriceSelected = false;
  bool isCreatingItem = false;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _meettimeController = TextEditingController();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    _detailController.dispose();
    _placeController.dispose();
    _meettimeController.dispose();
    super.dispose();
  }
///////////////////////////////////////////////////////////////
  void attemptCreateItem() async {
    if (FirebaseAuth.instance.currentUser == null) return print("1");
    // ?????? ?????? ??????
    isCreatingItem = true;

    // setState ????????? ?????????????????? ????????????,
    setState(() {
      autoValidate = AutovalidateMode.always;
    });


    final form = _fbKey.currentState;
  
    if (form == null || !form.validate()) {
      isCreatingItem = false;
      return print("2");
    }
    form.save();
    final inputValues = form.value;
    debugPrint(inputValues.toString());
    final String userKey = FirebaseAuth.instance.currentUser!.uid;
    final String userPhone = FirebaseAuth.instance.currentUser!.phoneNumber!;
    final String itemKey = ItemModel2.generateItemKey(userKey);
    List<Uint8List> images = SelectImageController.to.images;
    // final num? price = num.tryParse(_priceController.text.replaceAll('.', '').replaceAll(' ???', ''));
    final num? price =
        num.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), ''));
    // UserNotifier userNotifier = context.read<UserNotifier>();

    if (images.isEmpty) {
      dataWarning(context, '??????', '???????????? ??????????????????');
      return print("3");
    }

    if (CategoryController.to.currentCategoryInEng == 'none') {
      dataWarning(context, '??????', '??????????????? ??????????????????');
      return print("4");
    }

    // uploading raw data and return the Urls,
    List<String> downloadUrls = await ImageStorage.uploadImage(images, itemKey);
    // logger.d('upload finished(${downloadUrls.length}) : $downloadUrls');

    ItemModel2 itemModel = ItemModel2(
      itemKey: itemKey,
      userKey: userKey,
      userPhone: userPhone,
      imageDownloadUrls: downloadUrls,
      //
      place :_placeController.text,
      title: _titleController.text,
      detail: _detailController.text,
      meettime: _meettimeController.text,
      //
      category: CategoryController.to.currentCategoryInEng,
      price: price ?? 0,
      negotiable: _suggestPriceSelected,
      address: UserController.to.userModel.value!.address,
      //userNotifier.userModel!.address,
      geoFirePoint: UserController.to.userModel.value!.geoFirePoint,
      //userNotifier.userModel!.geoFirePoint,
      createdDate: DateTime.now().toUtc(),
    );

    // await ItemService().createNewItem(itemModel, itemKey, userNotifier.user!.uid);
    await ItemService()
        .createNewItem(itemModel, itemKey, UserController.to.user.value!.uid);

     Get.appUpdate();
     Get.back();
     }

  Future<bool> dataWarning(
      BuildContext context, String title, String msg) async {
    isCreatingItem = false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => WarningYesNo(
            title: title,
            msg: msg,
            yesMsg: '??????',
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;

        return IgnorePointer(
          ignoring: isCreatingItem,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              // leading ??? ????????? back ????????? "??????" ???????????? ????????? ??? ??????.
              leadingWidth: 55.0,
              leading: TextButton(
                onPressed: () {
                  debugPrint('???????????? ?????? ??????');
                  Get.back();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: Text(
                  '??????',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              // ???????????????,
              bottom: PreferredSize(
                preferredSize: Size(_size.width, 3),
                child: isCreatingItem
                    ? const LinearProgressIndicator(minHeight: 3)
                    : Container(),
              ),
              actions: <Widget>[
                TextButton(/////////////////////???????????????
                  onPressed:
                    attemptCreateItem,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    // ????????? ?????? ?????? ???????????? ?????????,
                    minimumSize: const Size(55, 40),
                  ),
                  child: Text(
                    '??????',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
              title: Text(
                '????????? ?????????.',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            // ???????????? ????????? ListView ??? ?????? ????????? ????????? ????????? ????????????,
            body: FormBuilder(
              key: _fbKey,
              child: ListView(
                children: <Widget>[
                  // ?????? ????????? ??????
                  const MultiImageSelect(),
                  dividerCustom,
// ???????????? ********************************************************
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding_16),
                    child: TextFormField(
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '???????????? ???????????????'),
                      ]),
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '(????????? ??????) ?????? ?????? ?????? ?????????',
                        // padding ?????? ?????? ?????? ???????????? ??????,
                        // contentPadding: const EdgeInsets.symmetric(horizontal: padding_16),
                        border: underLineBorder,
                        enabledBorder: underLineBorder,
                        focusedBorder: underLineBorder,
                        // error ?????? border ??????
                        errorBorder: underLineBorder,
                        focusedErrorBorder: underLineBorder,
                        // errorStyle: const TextStyle(color: Colors.grey)
                      ),
                    ),
                  ),
                  dividerCustom,
// ???????????? ?????? ********************************************************
                  ListTile(
                    onTap: () {
                      debugPrint('/LOCATION_INPUT/LOCATION_CATEGORY_INPUT');
                      Get.toNamed('/$ROUTE_CATEGORY_INPUT');
                    },
                    dense: true,
                    title: Obx(() {
                      return Text(CategoryController.to.currentCategoryInKor);
                    }),
                    trailing: const Icon(Icons.navigate_next),
                  ),
                  dividerCustom,
                  Row(
                    children: <Widget>[
                      // Expanded ??? ???????????? ?????? ????????? ???????????? ??????
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: padding_16),
// ???????????? ********************************************************
                          child: TextFormField(
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: '???????????? ???????????????'),
                            ]),
                            // ????????? ?????????????????? ??????,
                            keyboardType: TextInputType.number,
                            controller: _priceController,
                            onChanged: (value) {
                              if ('0 ???' == value) {
                                _priceController.clear();
                              }
                              setState(() {});
                            },
                            // ????????? ?????? ????????? ??????????????? ??????,
                            inputFormatters: [
                              MoneyInputFormatter(
                                  mantissaLength: 0, trailingSymbol: ' ???')
                            ],
                            decoration: InputDecoration(
                              hintText: ' ?????????',
                              prefixIcon: ImageIcon(
                                const ExtendedAssetImageProvider(
                                    'assets/imgs/won.png'),
                                // ????????? ???????????? ???????????? ?????? ????????? ????????????,
                                color: (_priceController.text.isEmpty)
                                    ? Colors.grey[350]
                                    : Colors.black87,
                              ),
                              // prefixIcon ??? ???????????? ??????,
                              prefixIconConstraints:
                                  const BoxConstraints(maxWidth: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: padding_08),
                              border: underLineBorder,
                              enabledBorder: underLineBorder,
                              focusedBorder: underLineBorder,
                              // error ?????? border ??????
                              errorBorder: underLineBorder,
                            ),
                          ),
                        ), ///?????????
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: padding_16),
                        child: TextButton.icon(
                          onPressed: () {
                            // ???????????? ????????? ?????? ???????????? ?????? ??????,
                            setState(() {
                              _suggestPriceSelected = !_suggestPriceSelected;
                            });
                          },
                          icon: Icon(
                            _suggestPriceSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _suggestPriceSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black54,
                          ),
                          label: Text(
                            '??????????????? ??????',
                            style: TextStyle(
                              color: _suggestPriceSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black54,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black45, backgroundColor: Colors.transparent,
                          ),
                        ),
                      )// ????????? ??????
                    ],
                  ), // ?????????
                  dividerCustom,
// ?????? ?????? **************************************************
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding_16),
                    child: TextFormField(
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '?????? ????????? ???????????????.'),
                      ]),
                      controller: _placeController,
                      // ?????? ????????? ????????????, ?????? ?????? ?????????,
                      maxLines: null,
                      // multiline ???????????? ???????????? ???????????? ?????????,
                      keyboardType: TextInputType.multiline,

                      decoration: InputDecoration(
                        hintText: '[??????] : ?????? ????????? ???????????????. ',
                        contentPadding: const EdgeInsets.symmetric(
                          // horizontal: padding_16,
                          vertical: padding_16,
                        ),
                        border: underLineBorder,
                        enabledBorder: underLineBorder,
                        focusedBorder: underLineBorder,
                        // error ?????? border ??????
                        errorBorder: underLineBorder,
                      ),
                    ),
                  ),
                  dividerCustom,
                  // ?????? ?????? **************************************************
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding_16),
                    child: TextFormField(
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '?????? ????????? ???????????????.'),
                      ]),
                      controller: _meettimeController,
                      // ?????? ????????? ????????????, ?????? ?????? ?????????,
                      maxLines: null,
                      // multiline ???????????? ???????????? ???????????? ?????????,
                      keyboardType: TextInputType.multiline,

                      decoration: InputDecoration(
                        hintText: '[??????] : ?????? ????????? ???????????????. ',
                        contentPadding: const EdgeInsets.symmetric(
                          // horizontal: padding_16,
                          vertical: padding_16,
                        ),
                        border: underLineBorder,
                        enabledBorder: underLineBorder,
                        focusedBorder: underLineBorder,
                        // error ?????? border ??????
                        errorBorder: underLineBorder,
                      ),
                    ),
                  ),
                  dividerCustom,
                  // ?????? ????????? ????????? ?????? **************************************************
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding_16),
                    child: TextFormField(
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '????????? ??????????????????'),
                      ]),
                      controller: _detailController,
                      // ?????? ????????? ????????????, ?????? ?????? ?????????,
                      maxLines: null,
                      // multiline ???????????? ???????????? ???????????? ?????????,
                      keyboardType: TextInputType.multiline,

                      decoration: InputDecoration(
                        hintText: '?????? ??????, ????????? ????????? ???????????? ???????????????.',
                        contentPadding: const EdgeInsets.symmetric(
                          // horizontal: padding_16,
                          vertical: padding_16,
                        ),
                        border: underLineBorder,
                        enabledBorder: underLineBorder,
                        focusedBorder: underLineBorder,
                        // error ?????? border ??????
                        errorBorder: underLineBorder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
