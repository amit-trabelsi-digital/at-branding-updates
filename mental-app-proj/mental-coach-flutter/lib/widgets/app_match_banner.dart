import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class AppMatchBanner extends StatelessWidget {
  final String timeLeft;
  final String gameDate;
  final double fontSize;
  final FontWeight? fontWeight;
  final String awayTeam;
  final String homeTeam;
  final String? imageAsset;

  const AppMatchBanner(
      {super.key,
      required this.timeLeft,
      required this.awayTeam,
      required this.homeTeam,
      required this.gameDate,
      this.fontSize = 20,
      this.fontWeight = FontWeight.bold,
      this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight, // Align to the left side
          child: Text("המשחק הקרוב",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              )),
        ),
        SizedBox(height: 5),
        SizedBox(
            width: double.infinity,
            height: 216,
            child: Stack(
              children: [
                // Image background
                if (imageAsset != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(imageAsset!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color.fromARGB(212, 0, 0, 0),
                      ],
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(children: [
                    SizedBox(
                      height: 45,
                    ),
                    AppTitle(
                      title: timeLeft,
                      color: Colors.white,
                      fontSize: 60,
                      verticalMargin: 0,
                    ),
                    Text(gameDate,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        )),
                    Text('$awayTeam - $homeTeam',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ))
                  ]),
                ),
              ],
            )),
      ],
    );
  }
}
