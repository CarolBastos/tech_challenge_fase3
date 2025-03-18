import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class UploadTransaction extends StatefulWidget {
  final Function(bool) onLoadingChange;

  UploadTransaction({Key? key, required this.onLoadingChange})
    : super(key: key);

  @override
  UploadTransactionState createState() => UploadTransactionState();
}

class UploadTransactionState extends State<UploadTransaction> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> _uploadedFiles = [];

  void reset() {
    setState(() {
      _uploadedFiles.clear();
    });
  }

  Future<void> pickFile() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _uploadedFiles = [
            {'name': pickedFile.name, 'path': pickedFile.path},
          ];
        });
      }
    } catch (e) {
      _showSnackBar("Erro ao selecionar arquivo.");
    }
  }

  Future<void> uploadToFirebase() async {
    if (_uploadedFiles.isEmpty) {
      _showSnackBar("Nenhum arquivo para enviar.");
      return;
    }

    widget.onLoadingChange(true);

    try {
      for (var fileData in _uploadedFiles) {
        File file = File(fileData['path']!);
        String fileName = path.basename(file.path);
        Reference storageRef = FirebaseStorage.instance.ref().child(
          'uploads/$fileName',
        );
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        _showSnackBar("Upload concluído!");
      }
      reset();
    } catch (e) {
      _showSnackBar("Erro ao enviar arquivo.");
    }

    widget.onLoadingChange(false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickFile,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file, size: 40, color: Colors.grey[700]),
              const SizedBox(height: 10),
              Text(
                'Adicionar recibo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _uploadedFiles.isNotEmpty
                  ? Column(
                    children:
                        _uploadedFiles.map((file) {
                          return Column(
                            children: [
                              if (file['path']!.isNotEmpty)
                                Image.file(
                                  File(file['path']!),
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(height: 5),
                              Text(
                                file['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  )
                  : Text(
                    "Toque para selecionar um arquivo",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
