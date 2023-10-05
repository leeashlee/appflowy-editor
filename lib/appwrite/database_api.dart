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
    client.setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);
    account = Account(client);
    databases = Databases(client);
  }

  Future<DocumentList> getNoteEntries() {
    return databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
    );
  }

  Future<Document> updateNoteEntry(String data) {
    return databases.updateDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
      documentId: data,
    );
  }
}
