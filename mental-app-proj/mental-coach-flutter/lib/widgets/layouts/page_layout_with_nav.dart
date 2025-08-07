import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final String? imageUrl;
  final String? imageSrc;
  final bool showBackButton;
  final Widget? optionalWidget;

  const AppPageLayout({
    super.key,
    required this.title,
    required this.child,
    this.imageUrl,
    this.imageSrc,
    this.showBackButton = true,
    this.optionalWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null || imageSrc != null;
    final bool useAssetImage = imageSrc != null;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: hasImage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 45,
                  color: hasImage ? Colors.white : Colors.black,
                ),
                onPressed: () => context.pop(),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: hasImage ? Colors.white : Colors.black,
                  fontSize: 50,
                  fontFamily: 'Barlev',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        actions: optionalWidget != null
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: optionalWidget!,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (hasImage)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: useAssetImage
                      ? AssetImage(imageSrc!) as ImageProvider
                      : NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            SizedBox(height: 0),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    child,
                    SizedBox(
                        height:
                            130), // הוספת רווח בתחתית כדי שהתוכן לא יוסתר מתחת לתפריט
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
