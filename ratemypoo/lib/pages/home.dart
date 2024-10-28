import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Scaffold is the way to structure the app
    return Scaffold(
      //appBar is the top section / header
      appBar: AppBar(
        title: const Text('ratemypoo'),
        backgroundColor: Colors.blue,
      
      
              //Daniel Section




      ),
      //body will be the main map section
      body: Stack(
        children: [
          const Placeholder(
            color: Colors.green,
            //add map api here
          ),
          //Positioned is where the filter button is
          Positioned(
            //position
            bottom: 16,
            right: 16,
            //filter button action
            child: FloatingActionButton(
              onPressed: () {
                //action when filter button is pressed
              },
              //Visual for the button
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),


              //Zheng = GoogleMap Section, Donovan = Positioned/FloatingActionButton (Filter Button)





      bottomNavigationBar: BottomNavigationBar(
        items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.red,
      ),
    );
  }
}