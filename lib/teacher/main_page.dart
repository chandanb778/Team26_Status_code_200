import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_vise/teacher/profile.dart';
import 'package:grade_vise/teacher/screens/grading.dart';
import 'package:grade_vise/teacher/screens/classroom_details.dart';
import 'package:grade_vise/teacher/screens/meet.dart';
import 'package:grade_vise/teacher/screens/uses_list.dart';
import 'package:grade_vise/utils/colors.dart';
import 'package:grade_vise/teacher/About/About.dart';

class MainPage extends StatefulWidget {
  final String classroomId;
  final String userPhoto;
  final String username;
  final String teacherPhoto;
  final int assignments;
  final String uid;

  final int students;

  const MainPage({
    super.key,
    required this.classroomId,
    required this.userPhoto,
    required this.username,
    required this.teacherPhoto,
    required this.assignments,
    required this.uid,

    required this.students,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final List<IconData> icons = [
    Icons.home_outlined,
    Icons.show_chart,
    Icons.videocam_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          backgroundColor: bgColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: ClipOval(child: Image.network(widget.teacherPhoto)),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuSection('CLASSROOM', [
                _buildMenuItem(Icons.home_outlined, 'View profile', 0, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyProfilePage()),
                  );
                }),
                _buildMenuItem(Icons.info, 'About', 1, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                }),
              ]),

              _buildMenuItem(Icons.info, 'Log Out', 1, () {
                FirebaseAuth.instance.signOut();
              }),
            ],
          ),
        ),
        backgroundColor: bgColor,
        body: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Builder(
                  builder: (context) {
                    return Expanded(
                      child: IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Image.asset(
                          "assets/images/teacher/components/more_options.png",
                        ),
                      ),
                    );
                  },
                ),

                IconButton(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.5,
                  ),
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/teacher/components/search.png",
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      widget.userPhoto.isEmpty
                          ? "https://i.pinimg.com/474x/59/af/9c/59af9cd100daf9aa154cc753dd58316d.jpg"
                          : widget.userPhoto,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  ClassroomDetails(
                    classroomId: widget.classroomId,
                    photoUrl: widget.userPhoto,
                    username: widget.username,
                  ),
                  Grading(
                    classroomId: widget.classroomId,
                    students: widget.students,
                    assignment: widget.assignments,
                  ),
                  Meet(
                    uid: widget.uid,
                    classroomId: widget.classroomId,
                    name: widget.username,
                    profilePic: widget.teacherPhoto,
                  ),
                  PeoplePage(
                    classroomId: widget.classroomId,
                    name: widget.username,
                    photoUrl: widget.userPhoto,
                    teacherPhoto: widget.teacherPhoto,
                    teachername: widget.username,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              topLeft: Radius.circular(50),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background effect
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left:
                    (MediaQuery.of(context).size.width / 4.45) * selectedIndex +
                    30, // Move based on index
                top: 12,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    icons.length,
                    (index) => _buildNavItem(index, icons[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int itemIndex, IconData iconData) {
    final bool isSelected = selectedIndex == itemIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = itemIndex;
          debugPrint(widget.username);
        });
      },
      child: Container(
        width: 55, // Match background width
        height: 55,
        alignment: Alignment.center,
        child: Icon(
          iconData,
          size: 28,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  // Build Menu Item (same as previous implementation)
  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}
