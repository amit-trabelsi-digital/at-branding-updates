import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';

class CaseAndReactPage extends StatefulWidget {
  final String title;
  final String imageSrc;
  final bool darkLinear;
  final CaseAndResponseModel caseAndResponseData;

  const CaseAndReactPage({
    super.key,
    required this.title,
    required this.imageSrc,
    this.darkLinear = true,
    required this.caseAndResponseData,
  });

  @override
  State<CaseAndReactPage> createState() => _CaseAndReactPageState();
}

class _CaseAndReactPageState extends State<CaseAndReactPage> {
  int _selectedIndex = 0; // Default to "וידאו"
  bool isVideoLoading = true;
  late WebViewController webViewController;
  bool _isVideoPlaying = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isVideoLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isVideoLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(
          getVimeoEmbedUrl(extractVimeoId(widget.caseAndResponseData.link))));
  }

  String getVimeoEmbedUrl(String videoId) {
    return 'https://player.vimeo.com/video/$videoId?autoplay=1&title=0&byline=0&portrait=0';
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define labels for toggle buttons - this was missing in your code
    final List<String> labels = ['וידאו', 'קולי'];
    // final videoUrl = Uri.parse(
    //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Image container
              Container(
                height: 360,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imageSrc),
                    fit: BoxFit.cover,
                  ),
                ),
                child: widget.darkLinear
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black, // Dark color at the bottom
                              const Color.fromARGB(
                                  76, 0, 0, 0), // Transparent at the top
                            ],
                          ),
                        ),
                      )
                    : null,
              ),

              // Position the AppCard to start halfway through the image container
              Padding(
                padding: const EdgeInsets.only(top: 190), // Half of 360
                child: AppCard(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppSubtitle(
                            subTitle: widget.title,
                            textAlign: TextAlign.start,
                            verticalMargin: 0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Image.asset(
                              'icons/close-icon.png',
                              width: 24,
                              height: 24,
                            ),
                          )
                        ],
                      ),
                      AppDivider(),
                      Text('עדיין לא הוגדר תוכן לדף זה',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      AppToggleButtons(
                          isSelected: [
                            _selectedIndex == 0,
                            _selectedIndex == 1
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          maxHeight: 36,
                          isRounded: true,
                          screenWidth: screenWidth * 0.8,
                          labels: labels),
                      SizedBox(height: 20),
                      _selectedIndex == 0
                          ? _buildVideoContent()
                          : _buildAudioContent(),
                      AppDivider(),
                    ],
                  ),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return _isVideoPlaying
        ? Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  const Color.fromARGB(220, 77, 77, 77)
                ],
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: WebViewWidget(
                    controller: webViewController,
                  ),
                ),
                if (isVideoLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _isVideoPlaying = true;
              });
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(45, 37, 37, 37),
                    const Color.fromARGB(220, 77, 77, 77)
                  ],
                ),
                // image: DecorationImage(
                //   image: NetworkImage(
                //       'https://i.vimeocdn.com/video/1231231_640x360.jpg'),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildAudioContent() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "תוכן אודיו יופיע כאן",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
