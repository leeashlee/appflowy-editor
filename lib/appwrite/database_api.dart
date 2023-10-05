import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:noel_notes/appwrite/auth_api.dart';
import 'package:noel_notes/appwrite/constants.dart';

class DatabaseAPI {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();

  DatabaseAPI() {
    init();
  }

  void init() {
    client.setEndpoint(appwriteUrl).setProject(appwriteProjectId);
    account = Account(client);
    databases = Databases(client);
  }

  Future<DocumentList> getNoteEntries() {
    return databases.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: collectionNoteEntry,
    );
  }

  Future<Document> updateNoteEntry(String data) {
    return databases.updateDocument(
      databaseId: appwriteDatabaseId,
      collectionId: collectionNoteEntry,
      documentId: data,
    );
  }
}
