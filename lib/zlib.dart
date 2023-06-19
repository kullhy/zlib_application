import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

class ZLib extends StatefulWidget {
  const ZLib({Key? key}) : super(key: key);

  @override
  State<ZLib> createState() => _ZLibState();
}


Future<void> compressFolder(String folderPath) async {
  final directory = Directory(folderPath);
  final folderName = directory.path.split('/').last; // Get the folder name
  final files = await directory.list(recursive: true).toList();

  final encoder = ZipEncoder();
  final zipFile = Archive();

  for (final file in files) {
    final filePath = file.path;
    final relativePath = p.relative(filePath, from: folderPath);

    if (file is File) {
      final bytes = await file.readAsBytes();
      zipFile.addFile(ArchiveFile(relativePath, bytes.length, bytes));
    }
  }

  final zipData = encoder.encode(zipFile);
  final parentDirectory = directory.parent;
  final zipFilePath = p.join(parentDirectory.path, '$folderName.zip'); // Use the folder name for the zip file
  await File(zipFilePath).writeAsBytes(zipData!);
  print('The folder has been compressed into a zip file: $zipFilePath');
}

Future<void> extractZipFile() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );

  if (result != null && result.files.isNotEmpty) {
    final File file = File(result.files.single.path!);
    final String zipFilePath = file.path;
    final String parentDirectory = file.parent.path;

    final ZipDecoder decoder = ZipDecoder();
    final Archive archive = decoder.decodeBytes(await file.readAsBytes());

    for (final ArchiveFile file in archive) {
      final String filePath = '${parentDirectory}/${file.name}';
      final File outputFile = File(filePath);
      if (file.isFile) {
        outputFile.createSync(recursive: true);
        outputFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    print('The zip file has been extracted to: $parentDirectory');
  }
}



class _ZLibState extends State<ZLib> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
            final folderPath = await FilePicker.platform.getDirectoryPath();
            if (folderPath != null) {
              await compressFolder(folderPath);
            } else {
              print('Không có thư mục được chọn');
            }
          },
          child: Text('Chọn và Nén Thư Mục'),
        ),
          
          SizedBox(height:10 ,),
          ElevatedButton(
            child: Text("un zlib"),
            onPressed: () {
              extractZipFile();
            },
          ),
        ],
      ),
    );
  }
}

