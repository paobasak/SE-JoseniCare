import 'package:flutter/material.dart';
//api service insert

class HealthSurveyCheck_in extends StatefulWidget {
  final String section;

  const HealthSurveyCheck_in({super.key, required this.section});

  @override
  _HealthSurveyCheck_inState createState() => _HealthSurveyCheck_inState();
}

class _HealthSurveyCheck_inState extends State<HealthSurveyCheck_in> {
  late String currentSection;
  int healthRating = 0;
  String areaAffected = "";
  String symptoms = "";
  DateTime? dateStarted;
  int painRating = 0;
  String painLocation = "";
  bool medicationtaken = false;
  DateTime? schedule;

  @override
  void initState() {
    super.initState();
    currentSection = widget.section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: currentSection == "symptomListing" ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,      appBar: _shouldShowAppBar()
          ? AppBar(
              title: Text(
                "Daily\nCheck-in",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(
                    right: 16.0,
                    bottom: BorderSide.strokeAlignCenter,
                  ),
                  child: Icon(Icons.menu, color: Colors.black, size: 26),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionContent(),
            const SizedBox(height: 40),
            _buildFAB(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (currentSection) {
      case "StartPage":
        return _buildStartContent();
      case "healthRating":
        return _healthRatingContent();
      case "symptomListing":
        return _buildSymptomListingContent();
      default:
        return _buildStartContent();
    }
  }

  Widget _buildStartContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 35),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Center(
            child: Container(
              width: 400,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'healthSurvey_1.png',
                  height: 800,
                  width: 800,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 65),
        const Center(
          child: Text(
            "Ready for today's check in?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _healthRatingContent() {
    String dateLabel = schedule != null ? formatDate(schedule!) : "DATE";

    return Column(
      children: [
        Container(
          color: Color(0xFF64D76B),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => currentSection = "StartPage");
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.menu, color: Colors.white, size: 28),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "So, how are you\nfeeling today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Icon(
                Icons.arrow_drop_down,
                size: 40,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),

              const SizedBox(height: 20),

              Container(
                width: 250,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      color: Colors.black26,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(child: healthImages()),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  int rating = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        healthRating = rating;
                      });

                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          currentSection = "symptomListing";
                        });
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: healthRating == rating
                            ? Colors.orange
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "$rating",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),

        ClipPath(
          clipper: TopWaveClipper(),
          child: Container(
            width: double.infinity,
            color: const Color(0xFF64D76B),
            padding: EdgeInsets.only(top: 30, bottom: 30),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: 30),
            Text(
              _getFeelingTitle(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _getFeelingDescription(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomListingContent() {
    return Center(   
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 40),
            Text(
              "Select the areas where\nyou're feeling unwell.",
              style: TextStyle(
                color: Colors.white,
              ), 
            ),
          ],
      ),
    );
  }
  //---------------------------------------//

  Widget _buildFAB() {
    switch (currentSection) {
      case "StartPage":
        return SizedBox(
          width: 300,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                schedule = DateTime.now();
                currentSection = "healthRating";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String formatDate(DateTime dt) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];

    String month = months[dt.month - 1];
    return "$month ${dt.day}";
  }

  bool _shouldShowAppBar() {
    return currentSection == "StartPage";
  }

  Widget healthImages() {
    switch (healthRating) {
      case 1:
        return SizedBox(
          width: 900,
          height: 900,
          child: Image.asset('$healthRating.png', fit: BoxFit.cover),
        );
      case 2:
        return Image.asset('2.png', height: 900, width: 900, fit: BoxFit.cover);
      case 3:
        return Image.asset('3.png', height: 900, width: 900, fit: BoxFit.cover);
      case 4:
        return Image.asset('4.png', height: 900, width: 900, fit: BoxFit.cover);
      case 5:
        return Image.asset('5.png', height: 900, width: 900, fit: BoxFit.cover);
      default:
        return Text(" ", style: TextStyle(fontSize: 80));
    }
  }

  String _getFeelingTitle() {
    switch (healthRating) {
      case 1:
        return "Feeling Great!";
      case 2:
        return "Okay";
      case 3:
        return "Neutral";
      case 4:
        return "Feeling Sick";
      case 5:
        return "Very Sick";
      default:
        return "...";
    }
  }

  String _getFeelingDescription() {
    switch (healthRating) {
      case 5:
        return "Your health seems severely affected.\nPlease rest and monitor closely.";
      case 4:
        return "Oh no! It seems that your health\nhas declined :(";
      case 3:
        return "Nothing unusual today.\nJust an average feeling.";
      case 2:
        return "Glad to hear you're feeling okay!";
      case 1:
        return "Awesome! You're feeling great today!";
      default:
        return "Take your time! We care for\nhow you're feeling.";
    }
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, 20);

    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 40);

    path.quadraticBezierTo(size.width * 0.75, 80, size.width, 40);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
