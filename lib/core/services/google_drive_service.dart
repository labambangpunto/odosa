import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_service.dart';

class GoogleDriveService {
  static const String _fileName = 'backup_keuangan.enc';

  static Future<drive.DriveApi?> _getDriveApi() async {
    final client = await GoogleAuthService.getAuthenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  static Future<bool> uploadBackup(String encryptedData) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_fileName'",
      );

      final bytes = utf8.encode(encryptedData);
      final media = drive.Media(Stream.value(bytes), bytes.length);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Timpa file jika sudah ada
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(drive.File(), fileId, uploadMedia: media);
      } else {
        // Buat file baru jika belum ada
        final driveFile = drive.File()
          ..name = _fileName
          ..parents = ['appDataFolder'];
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> downloadBackup() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    try {
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_fileName'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) return null;

      final fileId = fileList.files!.first.id!;
      final response = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytesList = await response.stream.toList();
      final flatBytes = bytesList.expand((element) => element).toList();
      return utf8.decode(flatBytes);
    } catch (e) {
      return null;
    }
  }
}
