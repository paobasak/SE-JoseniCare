import 'package:campuscare_flutter/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:campuscare_flutter/services/appointment_api.dart';

class AppointmentBooking extends StatefulWidget {
  final String section;

  const AppointmentBooking({super.key, required this.section});

  @override
  _AppointmentBookingState createState() => _AppointmentBookingState();
}

class _AppointmentBookingState extends State<AppointmentBooking> {
  late String currentSection;
  String selectedCampus = "";
  String selectedAppointmentType = "";
  String appointmentPurpose = "";
  String appointmentStatus = "";
  int visibleYear = DateTime.now().year;
  int visibleMonth = DateTime.now().month;
  int selectedDay = 0;
  int selectedMonth = 0;
  int selectedYear = 0;
  DateTime? schedule;
  List<dynamic>? pendingAppointments;
  List<int> unavailableHours = [];
  bool isLoadingSlots = false;
  Map<String, List<dynamic>> pendingCache = {};

  //BEGIN API CALL FUNCTION
  Future<void> sendAppointmentData() async {
    if (selectedCampus.isEmpty || selectedAppointmentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both campus and appointment type.'),
        ),
      );
      return;
    }

    try {
      final result = await AppointmentApi.createAppointment(
        campus: selectedCampus,
        type: selectedAppointmentType,
        purpose: appointmentPurpose,
        status: appointmentStatus,
        schedule: schedule!,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment successfully created!')),
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

  Future<void> fetchPendingAppointments() async {
    final dateStr =
        "${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}";

    // If already fetched today → SUPER FAST
    if (pendingCache.containsKey(dateStr)) {
      setState(() {
        pendingAppointments = pendingCache[dateStr];
      });
      return;
    }

    // If not fetched → slow because API, but only once per date
    final appointments = await AppointmentApi.getPendingSlots(dateStr);

    // Convert format
    final formatted = appointments
        .map((dt) => {"schedule": dt.toIso8601String()})
        .toList();

    // Cache it so next time it's instant
    pendingCache[dateStr] = formatted;

    setState(() {
      pendingAppointments = formatted;
    });
  }

  //end API CALL FUNCTION

  @override
  void initState() {
    super.initState();
    currentSection = widget.section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          "Schedule\nAppointment",
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
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(currentSection),
                child: _buildSectionContent(),
              ),
            ),
            const SizedBox(height: 70),
            _buildFAB(),
          ],
        ),


      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: _buildFooterText(),
      ),
    );
  }

  //===============================================================//
  //PAGE SECTIONS
  Widget _buildSectionContent() {
    switch (currentSection) {
      case "StartPage":
        return _buildStartContent();
      case "ScheduleAppointment":
        return _buildScheduleDateContent();
      case "appointmentSelection":
        return _buildAppointmentSelectionContent();
      case "DateSelection":
        return _buildCalendar();
      case "confirmBooking":
        return _buildConfirmBookingContent();
      case "bookingConfirmed":
        return _buildBookingConfirmedContent();
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
                  'booking_1.png',
                  height: 800,
                  width: 800,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDateContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: SizedBox(
                  width: 400,
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 70, top: 0),
                child: _cardSelectorText(),
              ),

              const SizedBox(height: 5),
              _optionSelector(
                optionTitle: "Main Campus",
                selected: selectedCampus == "Main Campus",
                onTap: () {
                  setState(() {
                    selectedCampus = "Main Campus";
                  });
                },
              ),
              _optionSelector(
                optionTitle: "Basak Campus",
                selected: selectedCampus == "Basak Campus",
                onTap: () {
                  setState(() {
                    selectedCampus = "Basak Campus";
                  });
                },
              ),
              _optionSelector(
                optionTitle: "Quadricenntenial Campus",
                selected: selectedCampus == "Quadricenntenial Campus",
                onTap: () {
                  setState(() {
                    selectedCampus = "Quadricenntenial Campus";
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentSelectionContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0, 19),
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: SizedBox(
                width: 400,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  value: 1.0,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 70, top: 0),
            child: _cardSelectorText(),
          ),

          const SizedBox(height: 5),
          _optionSelector(
            optionTitle: "General Check-up",
            selected: selectedAppointmentType == "General Check-up",
            onTap: () {
              setState(() {
                selectedAppointmentType = "General Check-up";
              });
            },
          ),

          _optionSelector(
            optionTitle: "Dental",
            selected: selectedAppointmentType == "Dental",
            onTap: () {
              setState(() {
                selectedAppointmentType = "Dental";
              });
            },
          ),

          if (selectedAppointmentType == "General Check-up")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE787),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Is this for an event?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _optionSelector(
                      optionTitle: "Yes (i.e., for intramurals)",
                      selected: appointmentPurpose == "Event",
                      onTap: () {
                        setState(() {
                          appointmentPurpose = "Event";
                        });
                      },
                    ),

                    _optionSelector(
                      optionTitle: "No, just a regular check-up",
                      selected: appointmentPurpose == "Regular Check-up",
                      onTap: () {
                        setState(() {
                          appointmentPurpose = "Regular Check-up";
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          if (selectedAppointmentType == "Dental")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE787),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What type of service do you need?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _optionSelector(
                      optionTitle: "Dental Cleaning",
                      selected: appointmentPurpose == "Dental Cleaning",
                      onTap: () {
                        setState(() {
                          appointmentPurpose = "Dental Cleaning";
                        });
                      },
                    ),

                    _optionSelector(
                      optionTitle: "Dental Filling",
                      selected: appointmentPurpose == "Dental Filling",
                      onTap: () {
                        setState(() {
                          appointmentPurpose = "Dental Filling";
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    int year = visibleYear;
    int month = visibleMonth;

    String monthName(int m) {
      const names = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
      return names[m - 1];
    }

    int nextMonth = month == 12 ? 1 : month + 1;

    int daysInMonth = DateTime(
      month == 12 ? year + 1 : year,
      month == 12 ? 1 : month + 1,
      0,
    ).day;

    int firstWeekdayIndex = DateTime(year, month, 1).weekday;

    int leadingEmptyCount = (firstWeekdayIndex == DateTime.sunday)
        ? 0
        : firstWeekdayIndex - 1;

    List<Widget> dayCells = [];

    for (int i = 0; i < leadingEmptyCount; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime d = DateTime(year, month, day);
      if (d.weekday == DateTime.sunday) continue;

      bool isPastDate = d.isBefore(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ));

      final bool isSelected =
          selectedDay == day && selectedMonth == month && selectedYear == year;

      dayCells.add(
        GestureDetector(
          onTap: isPastDate ? null: () async {
            setState(() {
              selectedDay = day;
              selectedMonth = month;
              selectedYear = year;
              pendingAppointments = null;
            });
            await fetchPendingAppointments();
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isPastDate ? const Color.fromARGB(255, 28, 28, 28) : (isSelected ? const Color(0xFF6EDC74) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "$day",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isPastDate
                    ? Colors.grey.shade700
                    : (isSelected ? Colors.black : Colors.white),

              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (visibleMonth == 1) {
                      visibleMonth = 12;
                      visibleYear--;
                    } else {
                      visibleMonth--;
                    }
                  });
                },
                child: Container(
                  width: 225,
                  height: 110,
                  decoration: BoxDecoration(color: const Color(0xFF6EDC74)),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          monthName(month).substring(0, 3).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 10,
                        top: 65,
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    if (visibleMonth == 12) {
                      visibleMonth = 1;
                      visibleYear++;
                    } else {
                      visibleMonth++;
                    }
                  });
                },
                child: Container(
                  width: 225,
                  height: 110,
                  decoration: BoxDecoration(color: const Color(0xFF555555)),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          monthName(nextMonth).substring(0, 3).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(150, 255, 255, 255),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 10,
                        top: 65,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("M", style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
              Text("T", style: TextStyle(color: Color.fromARGB(179, 9, 5, 5))),
              Text("W", style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
              Text("T", style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
              Text("F", style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
              Text("S", style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
            ],
          ),
        ),

        const SizedBox(height: 7),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 41, 41, 41),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 380,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              children: dayCells,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 5,
            runSpacing: 5,
            children: _generateTimeSlots(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmBookingContent() {
    String dateLabel = schedule != null ? formatDate(schedule!) : "DATE";

    String timeLabel = schedule != null
        ? formatTimeRange(schedule!)
        : "Time not set";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade300,
                value: 0.5,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                minHeight: 4,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Appointment\nDetails:",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 232, 229, 229),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Campus:", selectedCampus),
                  _infoRow("Type:", selectedAppointmentType),
                  _infoRow("Purpose:", appointmentPurpose),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              selectedAppointmentType,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "@$selectedCampus",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            const Center(
              child: Text(
                "Just one last step! Please confirm your booking",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => currentSection = "ScheduleAppointment"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Edit details"),
                  ),
                ),

                const SizedBox(width: 20),

                SizedBox(
                  width: 130,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => currentSection = "bookingConfirmed");
                      appointmentStatus = "Pending";
                      await sendAppointmentData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Book",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                "Did we get it right? Check the details above.\n"
                "Changes may still occur after confirmation.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper row
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBookingConfirmedContent() {
    String dateLabel = schedule != null ? formatDate(schedule!) : "DATE";

    String timeLabel = schedule != null
        ? formatTimeRange(schedule!)
        : "Time not set";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade300,
                value: 1,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                minHeight: 4,
              ),
            ),

            const SizedBox(height: 5),

            Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Center(
                child: Image.asset(
                  'booking_2.png',
                  height: 300,
                  width: 400,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 0),

            Center(
              child: Text(
                "Your appointment has been confirmed! See you on $dateLabel.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedAppointmentType,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "@$selectedCampus",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "What shall we do next?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

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
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Back to Home"),
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
                          MaterialPageRoute(builder: (context) => HomePage()),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          ],
        ),
      ),
    );
  }

  //END OF PAGE SECTIONS
  //==========================================================//

  //=========================================================//
  //PAGE FLOATING BUTTONS//
  Widget _buildFAB() {
    switch (currentSection) {
      case "StartPage":
        return SizedBox(
          width: 300,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentSection = "ScheduleAppointment";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Book',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                color: Colors.white,
              ),
            ),
          ),
        );

      case "ScheduleAppointment":
        return SizedBox(
          width: 150,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentSection = "appointmentSelection";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 51, 51, 51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(255, 90, 210, 94),
              ),
            ),
          ),
        );

      case "appointmentSelection":
        return SizedBox(
          width: 150,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentSection = "DateSelection";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 51, 51, 51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(255, 90, 210, 94),
              ),
            ),
          ),
        );

      case "DateSelection":
        return SizedBox(
          width: 150,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentSection = "confirmBooking";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 51, 51, 51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(255, 90, 210, 94),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  //=======================================================//

  //=========================================================//
  //CARD SELECTION//

  Widget _optionSelector({
    required String optionTitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 232, 232, 232),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(selected ? 50 : 20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              optionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (selected) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ] else ...[
              const Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  //=========================================================//

  //======================================================//
  //SWITCH FOOTER TEXTS//

  Widget _buildFooterText() {
    switch (currentSection) {
      case "StartPage":
        return const Text(
          "Schedule your appointment easily\nwith JoseniCare!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        );

      default:
        return const SizedBox.shrink();
    }
  }
  //=====================================================//

  //======================================================//
  //SWITCH FOOTER TEXTS//

  Widget _cardSelectorText() {
    switch (currentSection) {
      case "ScheduleAppointment":
        return const Text(
          "From which campus will you be\nscheduling your appointment?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        );
      case "appointmentSelection":
        return const Text(
          "Great! What type of\nappointment are you booking?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  //=====================================================//
  //SLOTS

  List<Widget> _generateTimeSlots() {
    List<Widget> slots = [];

    if (pendingAppointments == null) {
      return [const Center(child: CircularProgressIndicator())];
    }

    for (int hour = 8; hour <= 19; hour++) {
      if (hour == 12) continue;

      DateTime slotTime = DateTime(
        selectedYear,
        selectedMonth,
        selectedDay,
        hour,
        0,
      );

      String label;
      if (hour < 12) {
        label = "$hour:00 AM";
      } else if (hour == 12) {
        label = "12:00 PM";
      } else {
        label = "${hour - 12}:00 PM";
      }

      bool isAvailable = true;

      for (var a in pendingAppointments!) {
        DateTime booked = DateTime.parse(a["schedule"]);

        if (booked.year == slotTime.year &&
            booked.month == slotTime.month &&
            booked.day == slotTime.day &&
            booked.hour == slotTime.hour) {
          isAvailable = false;
          break;
        }
      }

      if (unavailableHours.contains(hour)) {
        isAvailable = false;
      }

      slots.add(
        GestureDetector(
          onTap: isAvailable
              ? () {
                  setState(() {
                    schedule = slotTime;
                  });
                }
              : null,
          child: Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (schedule != null &&
                      schedule!.year == slotTime.year &&
                      schedule!.month == slotTime.month &&
                      schedule!.day == slotTime.day &&
                      schedule!.hour == slotTime.hour)
                  ? const Color(0xFF6EDC74)
                  : (isAvailable ? Colors.white : Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return slots;
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

  String formatTimeRange(DateTime dt) {
    int hour = dt.hour;
    int minute = dt.minute;

    String formatTime(int h, int m) {
      String suffix = h >= 12 ? "PM" : "AM";
      int hour12 = h % 12 == 0 ? 12 : h % 12;
      String minStr = m.toString().padLeft(2, '0');
      return "$hour12:$minStr $suffix";
    }

    String start = formatTime(hour, minute);
    DateTime endDt = dt.add(const Duration(minutes: 30));
    String end = formatTime(endDt.hour, endDt.minute);

    return "$start - $end";
  }

  //=====================================================//
} //END
