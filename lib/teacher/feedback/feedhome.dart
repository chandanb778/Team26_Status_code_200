import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grade_vise/teacher/feedback/return_feedback.dart';

class FeedbackPageteach extends StatefulWidget {
  final String classroomId;
  const FeedbackPageteach({super.key, required this.classroomId});

  @override
  State<FeedbackPageteach> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPageteach> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2839),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2839),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFD3D3D3),
              radius: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card with enhanced shadows and animations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3D1EF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8D7A4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Feedbacks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table header with enhanced styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Student Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.arrow_upward_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white, height: 1),
          ),

          // Feedback list with enhanced styling
          StreamBuilder(
            stream:
                FirebaseFirestore.instance
                    .collection('feedbacks')
                    .where('classroomId', isEqualTo: widget.classroomId)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Expanded(
                  child: ListView.builder(
                    itemCount:
                        snapshot
                            .data!
                            .docs
                            .length, // Placeholder count, replace with actual list
                    itemBuilder: (context, index) {
                      return FeedbackListItem(
                        name: snapshot.data!.docs[index]['email'],
                        des: snapshot.data!.docs[index]['description'],
                        fileType: snapshot.data!.docs[index]['fileType'],
                        fileUrl: snapshot.data!.docs[index]['fileUrl'],
                        status: 'view feedback',
                        statusColor: Colors.white,
                        title: snapshot.data!.docs[index]['title'],
                        shade: index.isEven,
                      );
                    },
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class FeedbackListItem extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final bool shade;
  final String des;
  final String fileType;
  final String fileUrl;
  final String title;

  const FeedbackListItem({
    super.key,
    required this.name,
    required this.status,
    required this.fileType,
    required this.statusColor,
    required this.shade,
    required this.des,
    required this.fileUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StudentFeedbackDetailScreen(
                  studentName: name,
                  des: des,
                  title: title,
                  filePath: fileUrl,
                  fileType: fileType,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: shade ? Colors.grey.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
