import 'package:flutter/material.dart';

class AppointmentBooking extends StatelessWidget {
  final String section; // dynamic data

  const AppointmentBooking({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Schedule\nAppointment", 
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
          padding: EdgeInsets.only(right: 16.0, bottom: BorderSide.strokeAlignCenter),
          child: Icon(Icons.menu, color: Colors.black, size: 26),
        ),
      ],
      ),
      body: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
        Transform.translate(
          offset: const Offset(0, -40),
          child: Center(
          child: Container(
                width: 400,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[200], 
                  borderRadius: BorderRadius.circular(16), 
                ),
          child: Padding(padding: const EdgeInsets.all(8.0),
          child: Image.asset('booking_1.png', height: 800, width: 800, fit: BoxFit.contain),
          ),
          ),
          ),
        ),
        const SizedBox(height: 20),
       ],
       
      ),
       
      floatingActionButton: Padding(
        padding:EdgeInsetsGeometry.only(bottom: 55.0),
        child: SizedBox(
        width: 300,
        height: 70,
        child: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppointmentBooking(section: "ScheduleAppointment")),
            );
        },
        label: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),),
        backgroundColor: Colors.green,
        ),
      ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      

      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom:30),
          child: Text(
          "Schedule your appointment easily\nwith JoseniCare!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),),
      ),
    );
    
  }
}
