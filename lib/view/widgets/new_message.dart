import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart'; // Add this package to pubspec.yaml
import 'package:http/http.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messagesController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    messagesController.dispose();
    super.dispose();
  }

  // Helper function to extract username from email
  String _getUsernameFromEmail(String email) {
    return email.split('@')[0];
  }

  // Request camera permission
  Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog('Camera');
      return false;
    }

    return status.isGranted;
  }

  // Request storage/photos permission based on platform
  Future<bool> _requestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // For Android 13+ (SDK 33+)
      if (sdkInt >= 33) {
        status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
      } else {
        // For older Android versions
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }
    } else if (Platform.isIOS) {
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
    } else {
      return false; // Unsupported platform
    }

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog('Gallery');
      return false;
    }

    return status.isGranted;
  }

  // Show dialog to direct user to settings when permission is permanently denied
  void _showPermissionSettingsDialog(String permissionType) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('$permissionType Permission Required'),
            content: Text(
              'This app needs $permissionType permission to send images. '
              'Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  // Pick image from gallery with permission check
  Future<void> _pickImage() async {
    final hasPermission = await _requestStoragePermission();

    if (!hasPermission) {
      return;
    }

    final picker = ImagePicker();
    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: ${e.toString()}')),
      );
    }
  }

  // Take photo with camera with permission check
  Future<void> _takePhoto() async {
    final hasPermission = await _requestCameraPermission();

    if (!hasPermission) {
      return;
    }

    final picker = ImagePicker();
    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: ${e.toString()}')),
      );
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Show image source dialog
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
    );
  }

  // Save image locally and store path in Firestore
  Future<String?> _saveImageLocally() async {
    if (_selectedImage == null) {
      return null;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      // Generate unique ID for the image
      final imageId = const Uuid().v4();
      final extension = path.extension(_selectedImage!.path);
      final fileName = '$imageId$extension';

      // Get app's local documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/chat_images';

      // Create directory if it doesn't exist
      final directory = Directory(localPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Copy image to local storage with the unique name
      final savedImagePath = '$localPath/$fileName';
      await _selectedImage!.copy(savedImagePath);

      print('Image saved locally at: $savedImagePath');

      setState(() {
        _isUploading = false;
        _selectedImage = null;
      });

      // Return the local path as the "URL"
      return savedImagePath;
    } catch (error) {
      print('Error saving image locally: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isUploading = false;
      });
      return null;
    }
  }


Future<String?> uploadHardcodedImageToFirebase() async {
  const String imageUrl =
      'https://th.bing.com/th/id/R.34582bcd1f2313d02158df4e47123087?rik=LE9dsJaXkR%2bxJg&riu=http%3a%2f%2fweknowyourdreams.com%2fimages%2ftrees%2ftrees-07.jpg&ehk=fS7bCWA1J1cEgA2Z8Abx4idifVrJiRLc3Nip42qjm40%3d&risl=&pid=ImgRaw&r=0';

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Download image from URL
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final tempFile = File(path.join(tempDir.path, fileName));
    await tempFile.writeAsBytes(response.bodyBytes);

    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('downloaded_images/${user.uid}/$fileName');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'uploaded_by': user.uid,
        'source': 'hardcoded_url',
        'uploaded_at': DateTime.now().toIso8601String(),
      },
    );

    final uploadTask = storageRef.putFile(tempFile, metadata);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    print('Image uploaded to Firebase: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    print('Error uploading hardcoded image: $e');
    return null;
  }
}


  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) {
      return null;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate a unique filename with user ID prefix for better organization
      final fileName =
          '${user.uid}/${const Uuid().v4()}${path.extension(_selectedImage!.path)}';

      // Get file mime type
      final mimeType =
          'image/${path.extension(_selectedImage!.path).replaceFirst('.', '')}';

      // Create reference to Firebase Storage with user-specific path
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(fileName);

      // Create custom metadata
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'uploaded_by': user.uid,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      // Upload task with explicit metadata
      final uploadTask = storageRef.putFile(_selectedImage!, metadata);

      print('Starting Firebase upload...');
      // Listen for state changes, errors, and completion events
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print(
            'Firebase upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
          );
        },
        onError: (e) {
          print('Firebase upload error: $e');
        },
      );

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Firebase upload successful: $downloadUrl');

      return downloadUrl;
    } catch (error) {
      print('Firebase Storage upload error: $error');
      return null;
    }
  }

  // Method to handle either cloud or local storage based on results
  Future<Map<String, dynamic>?> _handleImageStorage() async {
    if (_selectedImage == null) {
      return null;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // First try Firebase Storage
      final imageUrl = await _uploadImageToFirebase();

      if (imageUrl != null) {
        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });

        return {'type': 'cloud', 'url': imageUrl};
      }

      // If Firebase upload failed, fall back to local storage
      final localPath = await _saveImageLocally();

      if (localPath != null) {
        return {'type': 'local', 'url': localPath};
      }
    } catch (error) {
      print('Image storage failed: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isUploading = false;
    });

    return null;
  }

  // Submit message to Firestore
  Future<void> _submitMessage() async {
    final message = messagesController.text;
    final hasImage = _selectedImage != null;

    // Return if both text and image are empty
    if (message.trim().isEmpty && !hasImage) {
      return;
    }

    FocusScope.of(context).unfocus();
    messagesController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    Map<String, dynamic>? imageData;

    // Handle image if selected
    if (hasImage) {
      imageData = await _handleImageStorage();
      if (imageData == null && message.trim().isEmpty) {
        return; // If image storage failed and no text, abort
      }
    }

    // Try to get user data from Firestore
    String username;
    String? userProfileImage;

    try {
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userData.exists && userData.data() != null) {
        // Use data from Firestore if available
        username =
            userData.data()!['username'] ??
            _getUsernameFromEmail(user.email ?? 'user@example.com');
        userProfileImage = userData.data()!['image_url'];
      } else {
        // If no data in Firestore, extract username from email
        username = _getUsernameFromEmail(user.email ?? 'user@example.com');
        userProfileImage = null;
      }
    } catch (e) {
      // In case of error, fall back to email-based username
      username = _getUsernameFromEmail(user.email ?? 'user@example.com');
      userProfileImage = null;
    }

    // Add message to Firestore with appropriate data structure
    try {
      final messageData = {
        'text': message.trim(),
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': username,
        'userImage': userProfileImage,
      };

      // Add image data if present
      if (imageData != null) {
        messageData['type'] = 'image';
        messageData['imageUrl'] = imageData['url'];
        messageData['imageStorageType'] =
            imageData['type']; // 'cloud' or 'local'
      } else {
        messageData['type'] = 'text';
      }

      await FirebaseFirestore.instance.collection('chat').add(messageData);
      print('Message successfully added to Firestore');
    } catch (e) {
      print('Error adding message to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    uploadHardcodedImageToFirebase(); // Call the function to upload hardcoded image
    return Column(
      children: [
        // Show image preview if selected
        if (_selectedImage != null)
          Container(
            margin: const EdgeInsets.all(10),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Message input area
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
          child: Row(
            children: [
              // Image picker button
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _isUploading ? null : _showImageSourceOptions,
                color: Theme.of(context).colorScheme.primary,
              ),

              // Text field
              Expanded(
                child: TextField(
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: messagesController,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    labelText: "Type a message here",
                  ),
                ),
              ),

              // Send button
              _isUploading
                  ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitMessage,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
