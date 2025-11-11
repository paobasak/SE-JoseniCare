import 'package:flutter/material.dart';
import 'booking.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome,",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "MaJureJan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.search, size: 26),
                      SizedBox(width: 16),
                      Icon(Icons.menu, size: 26),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Dashboards",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 120,
                child: PageView(
                  children: [
                    dashboardCard(),
                    dashboardCard(),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Categories",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    categoryItem(Icons.calendar_today, "Booking", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AppointmentBooking(section: "Booking")),
                      );
                    }),
                    categoryItem(Icons.folder, "Records", onTap: () 
                    {
                      // Navigate to Records Page
                    }),
                    categoryItem(Icons.medical_services, "Services", onTap: () {
                      // Navigate to Services Page
                    }),
                    categoryItem(Icons.check_circle, "Daily Check-In", onTap: () {
                      // Navigate to Daily Check-In Page
                    }),
                    categoryItem(Icons.card_giftcard, "Rewards", onTap: () {
                      // Navigate to Rewards Page
                    }),
                    categoryItem(Icons.access_time, "Appointments", onTap: () {
                      // Navigate to Appointments Page
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  static Widget dashboardCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static Widget categoryItem(IconData icon, String title, {VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap, 
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

}
