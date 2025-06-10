import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_vise/services/firebase_config.dart';

import 'package:grade_vise/utils/show_error.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final _firestore = FirebaseFirestore.instance;

  Future<String> createUser(
    BuildContext context,
    String uid,
    String fname,
    String email,
  ) async {
    String res = "";
    try {
      await _firestore.collection('users').doc(uid).set({
        "uid": uid,
        'name': fname,
        'email': email,
        "photoURL": "",
        'createdAt': DateTime.now(),
        'role': "",
        'classrooms': [],
      });
      res = "success";
    } catch (e) {
      if (context.mounted) {
        res = e.toString();
        showSnakbar(context, e.toString());
      }
    }
    return res;
  }

  Future<void> createClassroom(
    String name,
    String section,
    String subject,
    String room,
  ) async {
    try {
      String classroomId = Uuid().v1();
      String roomId = Uuid().v1();
      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(classroomId)
          .set({
            'uid': FirebaseAuth.instance.currentUser!.uid,
            'name': name,
            'section': section,
            'subject': subject,
            'room': roomId,
            'classroomId': classroomId,
            'createdAt': DateTime.now(),
            'users': [],
            'assignments': [],
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'classrooms': FieldValue.arrayUnion([classroomId]),
          });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> createAnncouncement(
    String uid,
    String classroomId,
    String mes,
    String name,
    String profilePic,
  ) async {
    String res = '';

    try {
      String announcementId = Uuid().v1();

      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .set({
            'announcementId': announcementId,
            'uid': uid,
            'classroomId': classroomId,
            'message': mes,
            'announcedBy': name,
            'profilePic': profilePic,

            'time': Timestamp.now(),
          });

      res = 'success';

      await FirebaseConfig().sendNotificationToAllUsers(mes, classroomId);
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> createFeedback(
    String classroomId,
    String title,
    String des,
    String email,
    String uid,
    String userPhoto,
    String? fileUrl,
    String? fileType,
  ) async {
    String res = '';

    try {
      String feebackId = Uuid().v1();

      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(feebackId)
          .set({
            'feedbackId': feebackId,
            'classroomId': classroomId,
            'title': title,
            'description': des,
            'email': email,
            'userPhoto': userPhoto,
            'fileUrl': fileUrl ?? '',
            'fileType': fileType ?? '',
            'userId': uid,
            'time': Timestamp.now(),
          });

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    final userid =
        await FirebaseFirestore.instance
            .collection('classrooms')
            .doc(classroomId)
            .get();

    FirebaseConfig().sendNotificationToTeacher(des, userid.data()!['uid']);

    return res;
  }

  Future<void> storeEvaluations(List<Map<String, dynamic>> evaluations) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    for (var evaluation in evaluations) {
      String uid = Uuid().v1();

      await db.collection("evaluations").doc(uid).set({
        'uid': evaluation['uid'],
        "mark": evaluation["mark"],
        "feedback": evaluation["feedback"],
        'classroomId': evaluation['classroomId'],
        'assignmentId': evaluation['assignmentId'],
        'summary': evaluation['summaryReport'],
        "timestamp": FieldValue.serverTimestamp(),
      });

      await db.collection('submissions').doc(evaluation['submissionId']).update(
        {'isChecked': true},
      );
    }
  }
}
