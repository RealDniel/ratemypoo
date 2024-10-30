import 'package:flutter/material.dart';
import 'package:ratemypoo/pages/map.dart';
import 'package:ratemypoo/pages/create.dart';
import 'package:ratemypoo/pages/favorite.dart';

//A widget state is created here
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//This is the stated widget, it contains all of the page's info
class _HomePageState extends State<HomePage> {

  //This counts the index, allowing the program to select the icon
  int _selectedIndex = 0;

  //This is the list where the pages will be held
  final List<Widget> _widgetOptions = [
    const MapWidget(),
    const CreateWidget(),
    const FavoriteWidget(),
  ];

  //This is a function that selets the specified icon
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  //This is the main widget that the app is based upon
  @override
  Widget build(BuildContext context) {
    //Scaffold is the way to structure the app
    return Scaffold(
      //appBar is the top section / header
      appBar: AppBar(
        title: 
          Row(
            children:[
              //Profile Icon
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.person),
                onPressed: () {
                  //Profile Button Aciton Here
                },
              ),
              //Spacer
              const Expanded(child: SizedBox(height:30)),
              //Logo
              const SizedBox(
                height: 80.0,
                child: Image(
                  image: AssetImage('assets/ratemypooLogo.png')
                ),
              ),
            ],
          ),
        backgroundColor: Colors.lightBlue,
      ),
      //body will be the main map section
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
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
        //Donovan: This is the footer, it has every single icon used
        unselectedLabelStyle: const TextStyle(
          color: Colors.black45,
        ),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
            ),
            label: 'Favorites',
          ),
        ],
        backgroundColor: Colors.lightBlue,
        unselectedItemColor: Colors.black45,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}