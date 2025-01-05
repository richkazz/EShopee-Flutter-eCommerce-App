import 'dart:io';

class FirestoreFilesAccess {
  FirestoreFilesAccess._privateConstructor();
  static FirestoreFilesAccess _instance =
      FirestoreFilesAccess._privateConstructor();
  factory FirestoreFilesAccess() {
    return _instance;
  }

  // Fake data structure to simulate file storage
  Map<String, String> _storage = {}; // path -> download URL

  Future<String> uploadFileToPath(File file, String path) async {
    // Simulate uploading by generating a fake download URL
    String downloadUrl = "fake_download_url_for_$path";

    // Store the path and URL in our fake storage
    _storage[path] = downloadUrl;

    return downloadUrl;
  }

  Future<bool> deleteFileFromPath(String path) async {
    if (_storage.containsKey(path)) {
      _storage.remove(path);
      return true;
    } else {
      throw Exception("File not found at path: $path");
    }
  }

  Future<String> getDeveloperImage() async {
    const filename = "about_developer/developer";
    List<String> extensions = <String>["jpg", "jpeg", "jpe", "jfif"];

    for (final ext in extensions) {
      String path = "$filename.$ext";
      if (_storage.containsKey(path)) {
        return _storage[path]!;
      }
    }

    throw Exception("No JPEG Image found for Developer");
  }
}
