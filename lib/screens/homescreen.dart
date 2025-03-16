import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sole_mate/models/shoes.dart';
import 'package:sole_mate/provider/products_provider.dart';
import 'package:sole_mate/screens/filtersscreen.dart';
import 'package:sole_mate/screens/preference.dart';
import 'package:sole_mate/screens/widget/drawer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onFirstBuild;
  const HomeScreen({Key? key, required this.onFirstBuild}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreen> {
  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  final CardSwiperController controller = CardSwiperController();
  late TutorialCoachMark tutorialCoachMark;
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _swipeLeftKey = GlobalKey();
  final GlobalKey _swipeUpKey = GlobalKey();
  final GlobalKey _swipeRightKey = GlobalKey();
  bool isFiltering = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool isOffline = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    createTutorial();
    checkFirstTime();
    checkInternetConnection();
    widget.onFirstBuild();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('firstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('firstTime', false);
      // Show tutorial after a short delay to ensure the UI is fully built
      Future.delayed(const Duration(milliseconds: 50), showTutorial);
    }
  }

  Future<void> checkLastSwipeData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastPageNumber = prefs.getInt('lastPageNumber');
    // final String? lastProductId = prefs.getString('lastProductId');

    print('Last swipe data: pageNumber=$lastPageNumber');
  }

  Future<void> saveLastSwipeData(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPageNumber', pageNumber);
    // await prefs.setString('lastProductId', productId);
  }

  void openFilterModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
              ),
            ],
          ),
          child: FilterModalBottomSheet(
            productProvider:
                Provider.of<ProductProvider>(context, listen: false),
          ),
        );
      },
    );
  }

  void checkInternetConnection() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: SafeArea(
        child: isOffline
            ? const Center(
                child: Text(
                  'You are not connected to the internet',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          key: _drawerKey,
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: isDarkMode
                              ? SvgPicture.asset(
                                  "assets/svgicons/drawerblack.svg")
                              : SvgPicture.asset(
                                  "assets/svgicons/drawerlight.svg"),
                        ),
                        isDarkMode
                            ? Image.asset(
                                "assets/images/logowhite.png",
                              )
                            : Image.asset("assets/images/logolight.png"),
                        InkWell(
                          key: _filterKey,
                          onTap: () {
                            openFilterModalBottomSheet(context);
                          },
                          child: isDarkMode
                              ? SvgPicture.asset(
                                  "assets/svgicons/filterblack.svg",
                                )
                              : SvgPicture.asset(
                                  "assets/svgicons/filterdark.svg"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: products.isEmpty
                          ? Center(
                              child: productProvider.isLoading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isFiltering
                                              ? 'No products available for your filters'
                                              : 'No products available for your preferences',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () {
                                            if (isFiltering) {
                                              openFilterModalBottomSheet(
                                                  context);
                                            } else {
                                              productProvider.reloadProducts();
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const PreferenceScreen()));
                                            }
                                          },
                                          child: Text(
                                            isFiltering
                                                ? 'Change Filters'
                                                : 'Change Preferences',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                            )
                          : Stack(
                              children: [
                                CardSwiper(
                                  allowedSwipeDirection:
                                      const AllowedSwipeDirection.only(
                                          right: true,
                                          up: true,
                                          left: true,
                                          down: false),
                                  controller: controller,
                                  cardsCount: products.length,
                                  onSwipe: _onSwipe,
                                  onEnd: () {
                                    if (!isLoadingMore && hasMore) {
                                      setState(() {
                                        isLoadingMore = true;
                                        currentPage++;
                                        products.clear();
                                      });

                                      productProvider
                                          .fetchMoreProducts()
                                          .then((List<Product> newProducts) {
                                        setState(() {
                                          isLoadingMore = false;

                                          if (newProducts.isNotEmpty) {
                                            //products.addAll(newProducts);
                                            log("Total products after update: ${products.length}");
                                          } else {
                                            hasMore = productProvider.hasMore;
                                          }
                                        });
                                      }).catchError((error) {
                                        setState(() {
                                          isLoadingMore = false;
                                        });
                                      });
                                    }
                                  },
                                  numberOfCardsDisplayed:
                                      products.length < 2 ? products.length : 2,
                                  backCardOffset: const Offset(15, -20),
                                  cardBuilder: (context, index,
                                      percentThresholdX, percentThresholdY) {
                                    final nextIndex =
                                        index + 1 < products.length
                                            ? index + 1
                                            : index;
                                    final fadeInOpacity = percentThresholdX
                                        .abs()
                                        .clamp(0.0, 1.0)
                                        .toDouble();

                                    return Stack(
                                      children: [
                                        Opacity(
                                          opacity: fadeInOpacity,
                                          child: ShoeCard(
                                              product: products[nextIndex]),
                                        ),
                                        ShoeCard(product: products[index]),
                                      ],
                                    );
                                  },
                                ),
                                Positioned(
                                  left: 10,
                                  top: MediaQuery.of(context).size.height * 0.5,
                                  child: GestureDetector(
                                    key: _swipeLeftKey,
                                    onPanUpdate: (details) {
                                      // Handle swipe left gesture
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: MediaQuery.of(context).size.width * 0.5,
                                  child: GestureDetector(
                                    key: _swipeUpKey,
                                    onPanUpdate: (details) {
                                      // Handle swipe up gesture
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: MediaQuery.of(context).size.height * 0.5,
                                  child: GestureDetector(
                                    key: _swipeRightKey,
                                    onPanUpdate: (details) {},
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    if (previousIndex < 0 || previousIndex >= productProvider.products.length) {
      return false;
    }

    final product = productProvider.products[previousIndex];
    log('Page Number: $currentPage, Product ID: ${product.id}');

    // Save the last swipe data into shared preferences
    saveLastSwipeData(currentPage);

    // Check if the data was saved correctly
    checkLastSwipeData();

    switch (direction) {
      case CardSwiperDirection.right:
        productProvider.likeProduct(product.id);
        showLikePopup(context);
        break;
      case CardSwiperDirection.left:
        productProvider.dislikeProduct(product.id);
        showDisLikePopup(context);
        break;
      case CardSwiperDirection.top:
        productProvider.favoriteProduct(product.id);
        showBookmarkPopup(context);
        break;
      default:
        return false;
    }

    return true;
  }

  void showLikePopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.30,
        left: MediaQuery.of(context).size.width * 0.25,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/heart.json',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Timer(const Duration(milliseconds: 1000), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void showBookmarkPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.33,
        left: MediaQuery.of(context).size.width * 0.31,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/animations/saved.json',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Timer(const Duration(milliseconds: 800), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void showDisLikePopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.29,
        left: MediaQuery.of(context).size.width * 0.055,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 205,
            height: 205,
            child: Lottie.asset(
              'assets/animations/brokenheartt.json',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Timer(const Duration(milliseconds: 1000), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
    showTutorial();
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.blue,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
      },
      onClickTarget: (target) {
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
      },
      onClickOverlay: (target) {
        // print('Clicked on overlay: $target');
      },
      onSkip: () {
        // print("Tutorial skipped");
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "drawerKey",
        keyTarget: _drawerKey,
        // shape: ShapeLightFocus.RRect,
        radius: 4,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 50,
              left: 30,
            ),
            builder: (context, controller) {
              return Container(
                width: 200, // Adjust this value as needed
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Menu",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "• View your profile\n• See saved shoes\n• Change password\n• Get support\n• Logout",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "filterKey",
        keyTarget: _filterKey,
        //  shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              top: 50,
              right: 30,
            ),
            builder: (context, controller) {
              return Container(
                width: 200, // Adjust this value as needed
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Filter Shoes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Customize your shoe search:\n• Color\n• Size\n• Price",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "swipeUpKey",
        keyTarget: _swipeUpKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.swipe_up, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Swipe Up to Save",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Save the shoe and see more save it!",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "swipeLeftKey",
        keyTarget: _swipeLeftKey,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.swipe, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Swipe Left to Dislike",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Move on to the next shoe",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "swipeRightKey",
        keyTarget: _swipeRightKey,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.swipe, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Swipe Right to Like",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We'll show you more shoes like this in the future!",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }
}

class ShoeCard extends StatelessWidget {
  final Product? product;

  ShoeCard({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (product == null) {
      return Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey[100]!,
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 20.0,
                        width: 100.0,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        height: 16.0,
                        width: 150.0,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        height: 16.0,
                        width: 80.0,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            if (product!.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  product!.thumbnail,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  // colorBlendMode: BlendMode.lighten,
                ),
              ),
           Positioned(
                bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.3, 
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            const Color.fromARGB(255, 255, 0, 0)
                                .withOpacity(0.0), 
                            const Color.fromARGB(255, 211, 56, 56).withOpacity(0.22),
                          ]
                        : [
                            const Color.fromARGB(255, 80, 209, 226).withOpacity(
                                0.0), 
                            const Color.fromARGB(255, 118, 211, 248)
                                .withOpacity(0.3),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product!.brand,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    product!.shoeName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '\$${product!.retailPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
