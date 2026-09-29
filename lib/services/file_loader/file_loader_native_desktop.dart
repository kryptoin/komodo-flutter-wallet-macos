import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:web_dex/services/file_loader/file_loader.dart';
import 'package:web_dex/shared/utils/zip.dart';

class FileLoaderNativeDesktop implements FileLoader {
  const FileLoaderNativeDesktop();

  /// Whether the macOS file-picker entitlement pre-flight checks have been
  /// skipped. Ad-hoc signed local builds cannot claim the user-selected file
  /// entitlements (restricted entitlements are rejected at launch), but they
  /// run unsandboxed where the native dialogs work regardless, so the checks
  /// are skipped once before first use. No-op on Windows/Linux.
  static bool _entitlementChecksSkipped = false;

  Future<void> _skipEntitlementChecksOnce() async {
    if (_entitlementChecksSkipped) return;
    try {
      await FilePicker.skipEntitlementsChecks();
      _entitlementChecksSkipped = true;
    } catch (_) {
      // Older file_picker versions without this method; the save/upload
      // calls below will surface any real entitlement errors.
    }
  }

  @override
  Future<void> save({
    required String fileName,
    required String data,
    required LoadFileType type,
  }) async {
    await _skipEntitlementChecksOnce();
    switch (type) {
      case LoadFileType.text:
        if (p.extension(fileName).toLowerCase() == '.json') {
          await _saveAsJsonFile(fileName, data);
        } else {
          await _saveAsTextFile(fileName, data);
        }
      case LoadFileType.compressed:
        await _saveAsCompressedFile(fileName, data);
    }
  }

  @override
  Future<void> upload({
    required void Function(String name, String content) onUpload,
    required void Function(String) onError,
    LoadFileType? fileType,
  }) async {
    await _skipEntitlementChecksOnce();
    try {
      final result = await FilePicker.pickFiles();
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      final selectedFile = File(path);
      final data = await selectedFile.readAsString();

      onUpload(file.name, data);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> _saveAsTextFile(String fileName, String data) async {
    final String suggestedName =
        p.extension(fileName).isEmpty ? '$fileName.txt' : fileName;
    final String? fileFullPath =
        await FilePicker.saveFile(fileName: suggestedName);
    if (fileFullPath == null) return;
    final File file = File(fileFullPath)..createSync(recursive: true);
    await file.writeAsString(data);
  }

  Future<void> _saveAsJsonFile(String fileName, String data) async {
    final String suggestedName =
        p.extension(fileName).isEmpty ? '$fileName.json' : fileName;
    final String? fileFullPath =
        await FilePicker.saveFile(fileName: suggestedName);
    if (fileFullPath == null) return;

    String prettyData = data;
    try {
      final dynamic decoded = json.decode(data);
      prettyData = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      // If not valid JSON, keep original content
    }

    final File file = File(fileFullPath)..createSync(recursive: true);
    await file.writeAsString(prettyData);
  }

  Future<void> _saveAsCompressedFile(
    String fileName,
    String data,
  ) async {
    final String? fileFullPath =
        await FilePicker.saveFile(fileName: '$fileName.zip');
    if (fileFullPath == null) return;

    final compressedBytes =
        createZipOfSingleFile(fileName: fileName, fileContent: data);

    final File compressedFile = File(fileFullPath);
    await compressedFile.writeAsBytes(compressedBytes);
  }
}
