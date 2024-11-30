import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ratemypoo/pages/map.dart';
import 'package:ratemypoo/pages/create.dart';
import 'package:ratemypoo/pages/favorite.dart';
import 'package:ratemypoo/services/auth_service.dart';

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

  //This stores the User's profile picture URL
  String? photoUrl;

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
              PopupMenuButton<String>(
                icon: photoUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(photoUrl!),)
                    : const Icon(Icons.person), //default = person icon
                onSelected: (String result) async {
                  if (result == 'sign_in') {
                    //sign in function
                    User? user = await AuthService().signInWithGoogle();
                    if (user != null) {
                      setState(() {
                      photoUrl = user.photoURL; // Update photoUrl after sign in
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Welcome, ${user.displayName}!'))
                      );
                    }
                  } else if (result == 'sign_out') {
                    //sign out function
                    await AuthService().signOut();
                    setState(() {
                    photoUrl = null; // Clear photoUrl on sign out
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You have signed out')),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'sign_in',
                    child: Text('Sign In'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'sign_out',
                    child: Text('Sign Out'),
                  ),
                ]
              ),
              //Spacer
              const Expanded(child: SizedBox(height:30)),
              //Logo
              const SizedBox(
                height: 80.0,
                child: Image(
                  image: AssetImage('assets/poologo.png')
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