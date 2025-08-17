import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gateofgames/global/app_colors.dart';
import 'package:gateofgames/global/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:gateofgames/widgets/interstitial_ad_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gateofgames/screens/games_screens/payment_confirmation.dart';
import 'package:gateofgames/widgets/ad_banner.dart';
import 'package:gateofgames/widgets/showdate.dart';

import '../../global/constarcts.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final bool isService;
  const ProductDetailsScreen({super.key, required this.productId, this.isService = false});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  String? errorMsg;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _selectedQty = 1;
  bool showAllReviews = false;

  @override
  void initState() {
    super.initState();
    fetchProduct().then((_) {
      updateUserProductView(userPhone: UserData.data!['phone']!, productId: widget.productId);
    });
    InterstitialAdWidget.interstitialAd.showAd();
  }

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
      if (doc.exists) {
        product = doc.data() as Map<String, dynamic>;
      } else {
        errorMsg = 'تعذر تحميل بيانات المنتج';
      }
    } catch (e) {
      errorMsg = 'تعذر تحميل بيانات المنتج';
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: Stack(
              children: [
                isLoading
                    ? const Center(child: CircularProgressIndicator(key: Key('loadingIndicator')))
                    : errorMsg != null
                    ? Center(
                        child: Text(
                          errorMsg!,
                          key: Key('errorMsg'),
                          style: TextStyle(color: colorScheme.error),
                        ),
                      )
                    : product == null
                    ? Center(
                        child: Text(
                          'تعذر تحميل بيانات المنتج',
                          key: Key('noProductMsg'),
                          style: TextStyle(color: colorScheme.onBackground),
                        ),
                      )
                    : MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3.h),
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3.h, offset: Offset(0, 3.h))],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3.h),
                                        child: AspectRatio(
                                          aspectRatio: 1.5,
                                          child: CachedNetworkImage(
                                            imageUrl: product!['imageUrl'],
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => Container(alignment: Alignment.center, child: CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => Container(
                                              color: colorScheme.surface,
                                              child: Icon(Icons.broken_image, size: 8.h, color: colorScheme.onSurface.withOpacity(0.5)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.5.h),
                                  Container(
                                    padding: EdgeInsets.all(3.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.h),
                                      color: colorScheme.surface,
                                      boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.08), blurRadius: 2.2.h, offset: Offset(0, 1.2.h))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            product!['isActive']
                                                ? Row(
                                                    children: [
                                                      Icon(Icons.check_circle, color: Colors.green, size: 2.6.h),
                                                      SizedBox(width: 1.h),
                                                      Text(
                                                        'مـتـوفـر',
                                                        key: Key('isActive'),
                                                        style: TextStyle(fontSize: 2.4.h, color: Colors.green, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Icon(Icons.cancel, color: colorScheme.error, size: 2.6.h),
                                                      SizedBox(width: 1.h),
                                                      Text(
                                                        'غـيـر مـتوفر',

                                                        key: Key('isActive'),
                                                        style: TextStyle(fontSize: 2.2.h, color: colorScheme.error, fontFamily: 'JannaR', fontWeight: FontWeight.w700),
                                                      ),
                                                    ],
                                                  ),
                                            Row(children: [favButton(widget.productId), shareButton(widget.productId)]),
                                          ],
                                        ),
                                        SizedBox(height: 2.2.h),
                                        if (product!['offerOn'] == true)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${product!['offerPrice'] ?? '-'}',
                                                    style: TextStyle(fontSize: 3.4.h, color: Colors.green[700], fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    ' ${product!['currency'] ?? ''}',
                                                    style: TextStyle(fontSize: 2.4.h, color: colorScheme.onSurface, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(width: 1.2.h),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 1.4.h, vertical: 0.5.h),
                                                    decoration: BoxDecoration(color: colorScheme.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(1.h)),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.local_offer, color: colorScheme.secondary, size: 14),
                                                        const SizedBox(width: 3),
                                                        Builder(
                                                          builder: (context) {
                                                            final price = product!['price'];
                                                            final offerPrice = product!['offerPrice'];
                                                            if (price is num && offerPrice is num && price > 0 && offerPrice < price) {
                                                              final discount = ((price - offerPrice) / price * 100).round();
                                                              if (discount >= 20) {
                                                                return Text(
                                                                  '$discount% خصم',
                                                                  style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontFamily: 'JannaR', fontSize: 1.6.h),
                                                                );
                                                              } else {
                                                                return Text(
                                                                  'عرض',
                                                                  style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontFamily: 'JannaR', fontSize: 1.6.h),
                                                                );
                                                              }
                                                            }
                                                            return Text(
                                                              'عرض',
                                                              style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontFamily: 'JannaR', fontSize: 1.6.h),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 100.w,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${product!['price'] ?? '-'} ${product!['currency'] ?? ''}',
                                                      style: TextStyle(
                                                        fontSize: 2.h,
                                                        decoration: TextDecoration.lineThrough,
                                                        decorationColor: colorScheme.onSurface,
                                                        decorationThickness: 2,
                                                        color: colorScheme.error,
                                                        fontFamily: 'JannaR',
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Builder(
                                                      builder: (context) {
                                                        final expiry = product!['offerExpiry'];
                                                        if (expiry != null && expiry is Timestamp) {
                                                          final expiryDate = expiry.toDate();
                                                          return CountdownTimerWidget(expiryDate: expiryDate, expiryDateColor: Colors.green, type: '');
                                                        } else {
                                                          return SizedBox();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            '${product!['price'] ?? '-'} ${product!['currency'] ?? ''}',
                                            style: TextStyle(fontSize: 2.8.h, color: colorScheme.onSurface, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                          ),
                                        SizedBox(height: 2.4.h),
                                        Text(
                                          product!['name'] ?? 'بدون اسم',
                                          key: const Key('productName'),
                                          style: TextStyle(fontSize: 3.2.h, fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontFamily: 'JannaR'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 1.6.h),
                                        Divider(color: colorScheme.outline.withOpacity(0.2)),
                                        SizedBox(height: 1.6.h),
                                        Row(
                                          children: [
                                            Text(
                                              'الوصف',
                                              key: const Key('productDescriptionTitle'),
                                              style: TextStyle(fontSize: 2.5.h, color: colorScheme.primary, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1.8.h),
                                        Text(
                                          product!['description'] ?? 'aa',
                                          key: const Key('productDescription'),
                                          style: TextStyle(fontSize: 2.2.h, color: colorScheme.onSurface, fontFamily: 'JannaR'),
                                        ),
                                        SizedBox(height: 1.6.h),

                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance.collection('products').doc(widget.productId).collection('ratings').snapshots(),
                                          key: const Key('productReviewsStream'),
                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text('تعذر تحميل التقييمات', style: TextStyle(fontFamily: 'JannaR')),
                                              );
                                            }
                                            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                                              return SizedBox.shrink();
                                            }
                                            final reviews = snapshot.data!.docs;
                                            final reviewsToShow = showAllReviews || reviews.length <= 3 ? reviews : reviews.take(3).toList();
                                            return Column(
                                              children: [
                                                Divider(color: colorScheme.outline.withOpacity(0.2)),
                                                SizedBox(height: 1.6.h),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'التقيمات',
                                                      key: const Key('productReviewsTitle'),
                                                      style: TextStyle(fontSize: 2.5.h, color: AppColors.primary, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                                    ),
                                                    if (reviews.length > 3)
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            showAllReviews = !showAllReviews;
                                                          });
                                                        },
                                                        child: Text(
                                                          showAllReviews ? 'إخفاء التقييمات' : 'عرض جميع التقييمات',
                                                          style: TextStyle(fontFamily: 'JannaR', color: AppColors.primary, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(height: 1.8.h),

                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: reviewsToShow.length,
                                                  itemBuilder: (context, index) {
                                                    final review = reviewsToShow[index];
                                                    final userPhone = review['userPhone'] ?? '';
                                                    return FutureBuilder<DocumentSnapshot>(
                                                      future: FirebaseFirestore.instance.collection('users').doc(userPhone).get(),
                                                      builder: (context, userSnapshot) {
                                                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                          return const ListTile(
                                                            title: Text('جاري تحميل بيانات المستخدم...', style: TextStyle(fontFamily: 'JannaR')),
                                                          );
                                                        }
                                                        if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                          return ListTile(
                                                            title: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(userPhone, style: TextStyle(fontFamily: 'JannaR')),
                                                                RatingStars(value: review['rating'] ?? 0),
                                                              ],
                                                            ),
                                                            subtitle: Text(review['feedback'] ?? '', style: TextStyle(fontFamily: 'JannaR')),
                                                          );
                                                        }
                                                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                                        final userName = userData?['name'] ?? userPhone;
                                                        final userAvatar = userData?['profile'];
                                                        return ListTile(
                                                          leading: userAvatar != null
                                                              ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(userAvatar), radius: 2.5.h)
                                                              : CircleAvatar(
                                                                  radius: 2.5.h,
                                                                  child: Icon(Icons.person, size: 2.5.h),
                                                                ),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      userName,
                                                                      style: TextStyle(fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    Text(
                                                                      userPhone,
                                                                      style: TextStyle(fontFamily: 'JannaR', fontSize: 1.6.h, color: Colors.grey),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(width: 8),
                                                              RatingStars(value: review['rating'] ?? 0),
                                                            ],
                                                          ),
                                                          subtitle: Text(review['feedback'] ?? '', style: TextStyle(fontFamily: 'JannaR')),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        if (product!['reviews'] != null && product!['reviews'].toString().trim().isNotEmpty) ...[
                                          Text(
                                            product!['reviews'],
                                            key: const Key('productReviews'),
                                            style: TextStyle(fontSize: 2.2.h, color: AppColors.boldBlackMOre, fontFamily: 'JannaR'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.8.h),
                                  Row(
                                    children: [
                                      if (product!['isActive'])
                                        if (!widget.isService || !product!['isActive'])
                                          Container(
                                            height: 6.2.h,
                                            width: 6.2.h,
                                            margin: EdgeInsets.only(left: 1.2.h),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: cartList.contains(widget.productId) ? AppColors.offWhite : AppColors.primary,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.8.h)),
                                                padding: EdgeInsets.zero,
                                                elevation: 3,
                                              ),
                                              onPressed: product!['isActive'] == true
                                                  ? () async {
                                                      await _addToCart(widget.productId);
                                                    }
                                                  : null,
                                              child: cartList.contains(widget.productId)
                                                  ? Icon(Icons.remove_shopping_cart_outlined, color: AppColors.primary, size: 3.2.h)
                                                  : Icon(Icons.add_shopping_cart_outlined, color: Colors.white, size: 3.2.h),
                                            ),
                                          ),

                                      Expanded(
                                        child: SizedBox(
                                          height: 6.2.h,
                                          child: ElevatedButton(
                                            key: const Key('buyNowButton'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.8.h)),
                                              padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                              elevation: 3,
                                            ),
                                            onPressed: product!['isActive'] == true
                                                ? () {
                                                    _showBuyModalBottomSheet(context, product!);
                                                  }
                                                : null,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.shopping_bag, color: Colors.white, size: 2.4.h),
                                                SizedBox(width: 1.w),
                                                Text(
                                                  'شراء الآن',
                                                  style: TextStyle(fontSize: 2.7.h, color: Colors.white, fontFamily: 'JannaR'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3.2.h),
                                  SizedBox(height: 3.2.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                Positioned(left: 0, right: 0, bottom: 0, child: BannerAdWidget()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBuyModalBottomSheet(BuildContext context, Map<String, dynamic> product) {
    Constarcts.myLoggingF('product: $product');
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    ValueNotifier<int> method = ValueNotifier<int>(0);
    var feesOn = product['feesOn'] ?? false;
    var fee = feesOn ? product['fees'] : {};
    final inputs = product['isService'] ? (product['inputs'] ?? []) : ['EMAIL'];
    if (inputs.isNotEmpty && inputs.length == 1 && inputs[0] == 'ID') {
      method.value = 1;
    } else if (inputs.isNotEmpty && inputs.length == 1 && inputs[0] == 'EMAIL') {
      method.value = 0;
    } else if (inputs.length == 2 && inputs.contains('ID')) {
      method.value = 1;
    } else {
      method.value = 0;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.7,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : colorScheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey, borderRadius: BorderRadius.circular(2.5)),
                              ),
                              Text(
                                'إتمام الشراء',
                                style: TextStyle(fontSize: 20, color: isDark ? colorScheme.onSurface : AppColors.boldBlackMOre, fontWeight: FontWeight.bold, fontFamily: 'JannaR'),
                              ),
                              SizedBox(height: 6),
                              Text(
                                product['name'] ?? '',
                                style: TextStyle(fontSize: 16, color: AppColors.primary, fontFamily: 'JannaR'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(18)),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'طريقة الشحن',
                                style: TextStyle(fontSize: 15, color: isDark ? colorScheme.primary : colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'JannaR'),
                              ),
                              SizedBox(height: 10),
                              if (widget.isService == true) ...[
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'البريد الإلكتروني',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                                    labelStyle: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                  ),
                                  style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                ),
                              ] else ...[
                                ValueListenableBuilder<int>(
                                  valueListenable: method,
                                  builder: (context, value, _) {
                                    return Column(
                                      children: [
                                        if ((product['inputs']).contains('EMAIL'))
                                          RadioListTile<int>(
                                            selectedTileColor: !isDark ? null : Colors.black,
                                            value: 0,
                                            activeColor: AppColors.primary,
                                            overlayColor: MaterialStateProperty.all(Colors.amber),
                                            groupValue: value,
                                            onChanged: (val) => method.value = val!,

                                            title: Column(
                                              children: [
                                                Text(
                                                  'البريد الإلكتروني وكلمة المرور',
                                                  style: TextStyle(fontSize: 14, color: isDark ? colorScheme.primary.withOpacity(0.7) : colorScheme.onPrimary.withOpacity(0.7), fontFamily: 'JannaR'),
                                                ),
                                                if (feesOn)
                                                  if (!fee['isId'])
                                                    Container(
                                                      padding: EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                                      child: Text(
                                                        'رسموم إضافية علي الشحن بال email ${fee['price'] ?? 0} ج.م ',
                                                        style: TextStyle(fontSize: 14, color: Colors.green, fontFamily: 'JannaR', fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        if (product['inputs'].length == 2)
                                          Row(
                                            children: [
                                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  'أو',
                                                  style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey, fontFamily: 'JannaR'),
                                                ),
                                              ),
                                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey)),
                                            ],
                                          ),
                                        if ((product['inputs']).contains('ID'))
                                          RadioListTile<int>(
                                            value: 1,
                                            activeColor: AppColors.primary,
                                            groupValue: value,
                                            onChanged: (val) => method.value = val!,
                                            title: Column(
                                              children: [
                                                Text(
                                                  'ID اللاعب',
                                                  style: TextStyle(fontSize: 14, color: isDark ? colorScheme.primary.withOpacity(0.7) : colorScheme.onPrimary.withOpacity(0.7), fontFamily: 'JannaR'),
                                                ),
                                                if (feesOn)
                                                  if (fee['isId'])
                                                    Container(
                                                      padding: EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                                      child: Text(
                                                        'رسموم إضافية علي الشحن بال ID ${fee['price'] ?? 0} ج.م',
                                                        style: TextStyle(fontSize: 14, color: Colors.green, fontFamily: 'JannaR', fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        AnimatedSwitcher(
                                          duration: Duration(milliseconds: 250),
                                          child: value == 0
                                              ? Column(
                                                  key: ValueKey(0),
                                                  children: [
                                                    SizedBox(height: 12),
                                                    TextField(
                                                      controller: emailController,
                                                      decoration: InputDecoration(
                                                        labelText: 'البريد الإلكتروني',
                                                        border: OutlineInputBorder(),
                                                        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                                                        labelStyle: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                      ),
                                                      style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                    ),
                                                    SizedBox(height: 12),
                                                    TextField(
                                                      controller: passwordController,
                                                      decoration: InputDecoration(
                                                        labelText: 'كلمة المرور',
                                                        border: OutlineInputBorder(),
                                                        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                                                        labelStyle: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                      ),
                                                      style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                      obscureText: true,
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  key: ValueKey(1),
                                                  children: [
                                                    SizedBox(height: 12),
                                                    TextField(
                                                      controller: idController,
                                                      decoration: InputDecoration(
                                                        labelText: 'ID اللاعب',
                                                        border: OutlineInputBorder(),
                                                        prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                                                        labelStyle: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                      ),
                                                      style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onSurface),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => Navigator.pop(context),
                              label: Text(
                                'إلغاء',
                                style: TextStyle(fontFamily: 'JannaR', color: Colors.red),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: Icon(Icons.check_circle_outline, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                if (widget.isService == true && emailController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('يرجى إدخال البريد الإلكتروني', style: TextStyle(fontFamily: 'JannaR')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (widget.isService != true) {
                                  if (method.value == 0 && (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور', style: TextStyle(fontFamily: 'JannaR')),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (method.value == 1 && idController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('يرجى إدخال ID اللاعب', style: TextStyle(fontFamily: 'JannaR')),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                }
                                List<Map<String, dynamic>> accountInfoList = [];
                                for (int i = 0; i < _selectedQty; i++) {
                                  Map<String, dynamic> accountInfo = {'email': '', 'password': '', 'playerId': '', 'isID': method.value == 1};
                                  if (widget.isService == true) {
                                    accountInfo['email'] = emailController.text;
                                  } else if (method.value == 0) {
                                    accountInfo['email'] = emailController.text;
                                    accountInfo['password'] = passwordController.text;
                                  } else {
                                    accountInfo['playerId'] = idController.text;
                                  }
                                  accountInfoList.add(accountInfo);
                                }
                                final userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .add({
                                      'products': [
                                        {'productId': widget.productId, 'qty': _selectedQty, 'accountInfoList': accountInfoList},
                                      ],
                                      'userPhone': userPhone,
                                      'status': 'pending_review',
                                      'gameId': product['gameId'] ?? '',
                                      'serviceId': product['serviceId'] ?? '',
                                      'createdAt': DateTime.now(),
                                    })
                                    .then((p) {
                                      Constarcts.myLoggingF(p.id);
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderConfirmationScreen(paymentIds: [p.id], isHasService: widget.isService, isSpecialRequests: false),
                                        ),
                                      );
                                    });
                              },
                              label: const Text(
                                'تأكيد الشراء',
                                style: TextStyle(color: Colors.white, fontFamily: 'JannaR', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: Text(
                            'جميع معلوماتك محمية وسيتم استخدامها فقط لإتمام الطلب',
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey, fontFamily: 'JannaR'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconButton favButton(String productId) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      key: Key('favButton_\u007f$productId'),
      style: ElevatedButton.styleFrom(backgroundColor: colorScheme.surfaceVariant),
      icon: Icon(
        (UserData.data != null && (UserData.data!['favList'] as List).contains(productId)) ? Icons.favorite : Icons.favorite_border,
        color: (UserData.data != null && (UserData.data!['favList'] as List).contains(productId)) ? colorScheme.error : colorScheme.onSurface.withOpacity(0.7),
      ),
      onPressed: () async {
        final userPhone = UserData.data?['phone'];
        if (userPhone == null) return;
        final favList = List<String>.from(UserData.data!['favList'] ?? []);
        final isFav = favList.contains(productId);
        final userRef = FirebaseFirestore.instance.collection('users').doc(userPhone);
        if (isFav) {
          await userRef.update({
            'favList': FieldValue.arrayRemove([productId]),
          });
          favList.remove(productId);
        } else {
          await userRef.update({
            'favList': FieldValue.arrayUnion([productId]),
          });
          favList.add(productId);
        }
        setState(() {
          UserData.data!['favList'] = favList;
        });
        await UserData.fetchUser(userPhone);
      },
    );
  }

  IconButton shareButton(String productId) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      key: Key('shareButton_\u007f$productId'),
      style: ElevatedButton.styleFrom(backgroundColor: colorScheme.surfaceVariant),
      icon: Icon(Icons.share, color: colorScheme.onSurface.withOpacity(0.7)),
      onPressed: () async {
        final userPhone = UserData.data?['phone'];
        if (userPhone == null) return;
        final productUrl = 'https://elbaba-store.com/product/$productId';
        await Clipboard.setData(ClipboardData(text: productUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم نسخ رابط المنتج',
              style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onInverseSurface),
            ),
            backgroundColor: colorScheme.inverseSurface,
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get cartList => List<Map<String, dynamic>>.from(UserData.data!['cartList'] ?? []);
  Future<void> _addToCart(String productId, {int qty = 1}) async {
    final colorScheme = Theme.of(context).colorScheme;
    final userPhone = UserData.data?['phone'];
    if (userPhone == null) return;
    final list = List<Map<String, dynamic>>.from(cartList);
    final idx = list.indexWhere((item) => item['productId'] == productId);
    if (idx != -1) {
      list.removeAt(idx);
      await UserData.updateUser(userPhone, {'cartList': list});
      setState(() {
        UserData.data!['cartList'] = list;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تمت إزالة المنتج من العربة',
                style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onError),
              ),
            ],
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      list.add({'productId': productId, 'qty': qty});
      await UserData.updateUser(userPhone, {'cartList': list});
      setState(() {
        UserData.data!['cartList'] = list;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تمت إضافة المنتج إلى العربة',
                style: TextStyle(fontFamily: 'JannaR', color: colorScheme.onPrimary),
              ),
            ],
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> updateUserProductView({required String userPhone, required String productId}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userPhone);
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final now = Timestamp.now();
    final userSnapshot = await userRef.get();
    final userViews = userSnapshot.data()?['views'] ?? {};
    final updatedViews = Map<String, dynamic>.from(userViews);
    if (updatedViews.containsKey(productId)) {
      updatedViews[productId]['count'] += 1;
      updatedViews[productId]['lastViewed'] = now;
    } else {
      updatedViews[productId] = {'count': 1, 'lastViewed': now};
    }
    await userRef.update({'views': updatedViews});
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final productSnap = await tx.get(productRef);
      final currentCount = productSnap.data()?['totalViews'] ?? 0;
      tx.update(productRef, {'totalViews': currentCount + 1});
    });
  }
}
