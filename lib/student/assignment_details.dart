import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:grade_vise/student/uploade_submisson.dart';
import 'package:grade_vise/widgets/pdf_viewer.dart';
import 'package:grade_vise/widgets/simple_dailog.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String title;
  final String dueDate;
  final String content;
  final String fileUrl;
  final String fileType;
  final String assignmentId;
  final String uid;
  final String classroomId;
  final bool isTeacher;
  final Color bgColor;

  const AssignmentDetailScreen({
    super.key,
    required this.title,
    required this.dueDate,
    required this.content,
    required this.fileUrl,
    required this.fileType,
    required this.bgColor,
    required this.assignmentId,
    required this.classroomId,
    required this.isTeacher,
    required this.uid,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    checkStudentSubmission();
  }

  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadedFileName;
  List<String> user = [];

  Future<void> checkStudentSubmission() async {
    try {
      var snap =
          await FirebaseFirestore.instance
              .collection('submissions')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .where('assignmentId', isEqualTo: widget.assignmentId)
              .get();
      for (var i = 0; i < snap.docs.length; i++) {
        user.add(snap.docs[i].data()['userId']);
      }
      debugPrint("$user ${widget.uid}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        title: Text('Assignment Details', style: TextStyle(fontSize: 28)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        backgroundColor: widget.bgColor,
        foregroundColor: _getContrastingColor(widget.bgColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment title with card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          widget.dueDate,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.content, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Assignment File Section
            if (widget.fileUrl.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment File',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFilePreview(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PdfViewerScreen(
                                        pdfUrl: widget.fileUrl,
                                      ),
                                ),
                              );
                            },
                            icon: Icon(Icons.open_in_new),
                            label: Text('Open File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Upload Section
            widget.isTeacher
                ? Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Your Assignment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (user.contains(
                                FirebaseAuth.instance.currentUser!.uid,
                              )) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => CustomSimpleDailog(
                                        mes:
                                            'You already submitted this assignment',
                                        title: 'already submitted',
                                      ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UploadeSubmisson(
                                          assignmentId: widget.assignmentId,
                                          uid: widget.uid,
                                          classroomId: widget.classroomId,
                                        ),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.upload_file),
                            label: Text('Upload Assignment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    String fileExtension = widget.fileType.toLowerCase();

    // For image files
    if (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.fileUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text('Error loading image'),
            );
          },
        ),
      );
    }
    // For document files
    else {
      IconData iconData;
      String fileTypeText;

      switch (fileExtension) {
        case 'pdf':
          iconData = Icons.picture_as_pdf;
          fileTypeText = 'PDF Document';
          break;
        case 'doc':
        case 'docx':
          iconData = Icons.description;
          fileTypeText = 'Word Document';
          break;
        case 'ppt':
        case 'pptx':
          iconData = Icons.slideshow;
          fileTypeText = 'PowerPoint Presentation';
          break;
        default:
          iconData = Icons.insert_drive_file;
          fileTypeText = 'Document';
      }

      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 48, color: _getFileColor(fileExtension)),
            const SizedBox(height: 8),
            Text(
              fileTypeText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _extractFileName(widget.fileUrl),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }

  Color _getFileColor(String fileExtension) {
    switch (fileExtension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last.split('?').first;
      }
      return 'File';
    } catch (e) {
      return 'File';
    }
  }

  Color _getContrastingColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use black or white text
    double luminance =
        (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
