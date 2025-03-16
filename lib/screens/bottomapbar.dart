import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sole_mate/provider/favouritized.dart';
import 'package:sole_mate/provider/products_provider.dart';
import 'package:sole_mate/provider/profileprovider.dart';
import 'package:sole_mate/screens/favouriteitems.dart';
import 'package:sole_mate/screens/homescreen.dart';
import 'package:sole_mate/screens/profile_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
 int currentIndex = 0;
  bool showTutorial = true;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
   _screens = [
   HomeScreen(onFirstBuild: _showTutorialIfNeeded),
  ProfilePage(),
  FavoritedProductsScreen(),
];
    _onBottomNavBarItemTapped(0);
  }

  void _showTutorialIfNeeded() {
    if (showTutorial) {
      showTutorial = false;
      // Show tutorial
    }
  }
  

  void _onBottomNavBarItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    // Fetch products only the first time the Home tab is opened
    if (index == 0) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts(); 
      }
    } else if (index == 1) {
      Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile(); 
    } else if (index == 2) {
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavoritedProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 90),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.3,
              child: SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  onPressed: () {
                    _onBottomNavBarItemTapped(0);
                  },
                  shape: const CircleBorder(),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF23A5D9),
                          Color(0xFF5BCCD9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgicons/home.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/svgicons/bookmark.svg',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      _onBottomNavBarItemTapped(2); // Open Favorites tab
                    },
                  ),
                  const SizedBox(width: 35),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/svgicons/profile.svg',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      _onBottomNavBarItemTapped(1); // Open Profile tab
                    },
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

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromARGB(255, 28, 28, 28),
          Color.fromARGB(255, 28, 28, 28),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(
      Offset(size.width * 0.60, 15),
      radius: const Radius.circular(30.0),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
