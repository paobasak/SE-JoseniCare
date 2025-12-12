import 'package:flutter/material.dart';
import 'package:campuscare_flutter/services/healthsurvey_api.dart';
import 'package:campuscare_flutter/pages/homepage.dart';

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

  final Map<String, List<String>> regionSymptoms = {
    "head": ["Headache", "Dizziness", "Nasal congestion", "Eye strain"],
    "chest": ["Chest tightness", "Shortness of breath", "Coughing"],
    "stomach": ["Stomach pain", "Cramps", "Bloating", "Nausea"],
  };

  final Map<String, List<String>> regionPainLocations = {
    "head": ["Forehead", "Temple", "Back of head", "Behind eyes"],
    "chest": ["Left chest", "Right chest", "Center chest"],
    "stomach": ["Upper abdomen", "Lower abdomen", "Left side", "Right side"],
  };

  String selectedRegion = "head";

  Future<void> sendHealthReport() async {
    if (selectedRegion.isEmpty || dateStarted == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a region and provide a start date.'),
        ),
      );
      return;
    }

    try {
      final result = await HealthApi.submitReport(
        healthRating: healthRating,
        areaAffected: areaAffected,
        symptoms: symptoms,
        dateStarted: dateStarted!,
        painRating: painRating,
        painLocation: painLocation,
        medicationTaken: medicationtaken,
        schedule: schedule,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health report successfully submitted!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${result['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    currentSection = widget.section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentSection == "symptomListing"
          ? const Color.fromARGB(255, 26, 26, 26)
          : Colors.white,
      appBar: _shouldShowAppBar()
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
      case "narrowSymptom":
        return _buildNarrowSymptomContent();
      case "reportHealth":
        return _reportHealth();
      case "reportSubmitted":
        return _reportConfirmationContent();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Let's talk about your symptoms,\nwhere are you feeling unwell?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = constraints.maxWidth.clamp(250.0, 380.0);
              final imageHeight = imageWidth * 1.4;

              return Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;

                    final local = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    final dx =
                        (local.dx - (constraints.maxWidth - imageWidth) / 2)
                            .clamp(0.0, imageWidth);
                    final dy = local.dy.clamp(0.0, imageHeight);
                    final rel = Offset(dx / imageWidth, dy / imageHeight);

                    String? region = _detectRegionFromRelativeOffset(rel);
                    if (region != null) {
                      setState(() => selectedRegion = region.toLowerCase());
                      _showRegionPopup(region);
                    } else {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Tap a highlighted area (head, throat, stomach)",
                          ),
                          duration: Duration(milliseconds: 700),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: imageWidth,
                    height: imageHeight,
                    child: Image.asset(
                      "anatomy_front.png",
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      selectedRegion[0].toUpperCase() +
                          selectedRegion.substring(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => currentSection = "narrowSymptom");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 14,
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNarrowSymptomContent() {
    final symptomsList = regionSymptoms[selectedRegion.toLowerCase()] ?? [];
    final painLocations =
        regionPainLocations[selectedRegion.toLowerCase()] ?? [];

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            child: Row(
              children: [
                const SizedBox(height: 40),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () =>
                      setState(() => currentSection = "symptomListing"),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.0),
            child: Text(
              "Let's narrow it down..what are you feeling?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(65),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedRegion.isNotEmpty)
                              Text(
                                selectedRegion[0].toUpperCase() +
                                    selectedRegion.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Container(height: 2, color: Colors.green),
                            const SizedBox(height: 20),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: symptomsList.map((symptom) {
                                final bool isSelected = symptoms == symptom;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => symptoms = symptom),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 140),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green
                                          : const Color(0xFF1F1F1F),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      symptom,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              "Follow up questions:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(height: 2, color: Colors.green),
                            const SizedBox(height: 20),

                            const Text(
                              "1.) When did it start?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: dateStarted ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => dateStarted = date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E5E5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  dateStarted != null
                                      ? "${dateStarted!.month}/${dateStarted!.day}/${dateStarted!.year}"
                                      : "Select date",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              "2.) How bad is the pain?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: List.generate(10, (index) {
                                final value = index + 1;
                                final isSelected = painRating == value;

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => painRating = value),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green
                                          : const Color(0xFF4A4A4A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      value.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              "3.) Where is the pain located?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: painLocation.isNotEmpty
                                    ? painLocation
                                    : null,
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text("Select location"),
                                items: painLocations
                                    .map(
                                      (loc) => DropdownMenuItem(
                                        value: loc,
                                        child: Text(loc),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => painLocation = value ?? ""),
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              "4.) Are you currently taking any medication for this?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildChoiceButton(
                                  label: "Yes",
                                  selected: medicationtaken == true,
                                  onTap: () =>
                                      setState(() => medicationtaken = true),
                                ),
                                const SizedBox(width: 12),
                                _buildChoiceButton(
                                  label: "No",
                                  selected: medicationtaken == false,
                                  onTap: () =>
                                      setState(() => medicationtaken = false),
                                ),
                              ],
                            ),

                            const SizedBox(height: 36),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Section: Questions",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => setState(
                                    () => currentSection = "reportHealth",
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    "Next",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.green : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _reportHealth() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(255, 37, 37, 37),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () =>
                            setState(() => currentSection = "symptomListing"),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const Text(
                  "Alright, here's an overview\nof what we know:",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white24.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Symptom", symptoms),
                          _infoRow(
                            "Start",
                            dateStarted != null
                                ? "${dateStarted!.month}/${dateStarted!.day}/${dateStarted!.year}"
                                : "Not set",
                          ),
                          _infoRow("Pain level", painRating.toString()),
                          _infoRow("Area affected", painLocation),
                          _infoRow(
                            "Medicating",
                            medicationtaken ? "Yes" : "No",
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedRegion.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 130),

                const Text(
                  "Health Advisory:\nIf your symptoms continue to worsen, or you are experiencing constant discomfort for more than 3–5 days, please seek a doctor in the university's clinic.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 18, 18),
                  elevation: 16,
                  shadowColor: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    currentSection = "reportSubmitted";
                  });
                  await sendHealthReport();
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportConfirmationContent() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF64D76B),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('healthsurvey_2.png', width: 300, height: 300),
                SizedBox(height: 20),
                Text(
                  "Report Submitted!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => setState(
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Back to Home",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 29, 29, 29),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Thank you for submitting your health report.\nTake care and stay healthy!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
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
    switch (currentSection) {
      case "StartPage":
      case "reportSubmitted":
        return true;
      default:
        return false;
    }
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

  Widget _symptomChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _medButton(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String? _detectRegionFromRelativeOffset(Offset rel) {
    final x = rel.dx;
    final y = rel.dy;

    if (x > 0.32 && x < 0.68 && y > 0.02 && y < 0.20) return 'Head';

    if (x > 0.36 && x < 0.65 && y > 0.20 && y < 0.40) return 'Throat';

    if (x > 0.30 && x < 0.70 && y > 0.60 && y < 0.86) return 'Stomach';

    return null;
  }

  void _showRegionPopup(String region) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  region,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(
                    () => selectedRegion = areaAffected = region.toLowerCase(),
                  );
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Select",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
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
