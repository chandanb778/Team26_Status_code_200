import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_vise/screens/mobile_screen.dart';
import 'package:grade_vise/services/firebase_auth_methods.dart';

import 'package:grade_vise/student/join_class_dialog.dart';
import 'package:grade_vise/student/main_page.dart';
import 'package:grade_vise/utils/colors.dart';
import 'package:grade_vise/widgets/classroom_container.dart';

import 'package:intl/intl.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  _JoinClassScreenState createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  void _joinClass(String uid) async {
    // Show the dialog to enter class code
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => JoinClassDialog(uid: uid),
    );

    if (result != null && result is String) {
      setState(() {
        _isJoining = true;
      });

      // Simulate API call to join class
      await Future.delayed(const Duration(seconds: 2));

      // Here you would add your actual API call to join the class
      // For example:
      // final success = await ClassService.joinClass(result);

      setState(() {
        _isJoining = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined the class: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF1F2937),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xFF1F2937),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    // Header with profile picture
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi ${userData['name'].split(" ")[0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${int.parse(DateFormat('yyyy').format(DateTime.now()))}-${int.parse(DateFormat('yyyy').format(DateTime.now())) + 1}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              FirebaseAuthMethods(
                                FirebaseAuth.instance,
                              ).signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MobileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoURL'] == null ||
                                        userData['photoURL'].isEmpty
                                    ? "https://i.pinimg.com/474x/59/af/9c/59af9cd100daf9aa154cc753dd58316d.jpg"
                                    : userData['photoURL'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45),
                          ),
                        ),
                        child:
                            userData.containsKey('classrooms') &&
                                    userData['classrooms'] is List &&
                                    (userData['classrooms'] as List).isNotEmpty
                                ? StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('classrooms')
                                          .where(
                                            'classroomId',
                                            whereIn: List<String>.from(
                                              userData['classrooms'],
                                            ),
                                          )
                                          .snapshots(),
                                  builder: (context, classSnapshot) {
                                    if (!classSnapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount:
                                          classSnapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        final classData =
                                            classSnapshot.data!.docs[index]
                                                    .data()
                                                as Map<String, dynamic>;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 20,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              final snap =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(classData['uid'])
                                                      .get();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => MainPageScreen(
                                                        email:
                                                            userData['email'],
                                                        uid: userData['uid'],
                                                        classData: classData,
                                                        teahername:
                                                            snap.data()!['name'],
                                                        teacherPhoto:
                                                            snap.data()!['photoURL'],
                                                        name: userData['name'],
                                                        photoUrl:
                                                            userData['photoURL'] ==
                                                                        null ||
                                                                    userData['photoURL']
                                                                        .isEmpty
                                                                ? "https://i.pinimg.com/474x/59/af/9c/59af9cd100daf9aa154cc753dd58316d.jpg"
                                                                : userData['photoURL'],
                                                        classroomId:
                                                            classData['classroomId'],
                                                      ),
                                                ),
                                              );
                                            },
                                            child: ClassroomContainer(
                                              classroomName: classData['name'],
                                              room: classData['room'],
                                              section: classData['section'],
                                              subject: classData['subject'],

                                              color:
                                                  colors[Random().nextInt(
                                                    colors.length,
                                                  )],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 100,
                                      color: bgColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 240,
                                          height: 56,
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                () =>
                                                    _joinClass(userData['uid']),
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            label:
                                                _isJoining
                                                    ? const CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )
                                                    : const Text(
                                                      'Let\'s Start',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bgColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: InkWell(
                    onTap: () => _joinClass(userData['uid']),
                    child: Container(
                      height: 60,
                      width: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black,
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
