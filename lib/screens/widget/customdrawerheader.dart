import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sole_mate/provider/profileprovider.dart';
import 'package:sole_mate/utils/appcolors.dart';

class CustomDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Getting the profileProvider instance from the context
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Container(
      height: 200,
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Circular Image
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: profileProvider.profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileProvider.profileImageUrl,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          )
                        : SvgPicture.asset(
                            'assets/svgicons/male.svg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                
              ),
              
            ),
            const SizedBox(width: 5),

            // Column for Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    profileProvider.name, 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profileProvider.email, 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
